package main

import (
	"bytes"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"math/big"
	"net"
	"os"
	"os/signal"
	"sort"
	"strconv"
	"syscall"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/rlimit"
	"github.com/dchest/siphash"
	"github.com/docopt/docopt-go"
	"github.com/vishvananda/netlink"
)

type Config struct {
	NumberOfCollumns uint64 `json:"number_of_table_columns"`
	HashingKey       string `json:"hashing_key"`
}

type Binds *struct {
	IPAddress string `json:"ip"`
	Port      uint16 `json:"port"`
	Protocol  string `json:"proto"`
}

type BindsRowKey struct {
	IPAddress uint32
	Port	  uint16
	Protocol  uint8
}

type Backends *struct {
	IPAddress    string `json:"ip"`
	State        string `json:"state"`
	InterfaceID  uint32	`json:"interface_id"`
	HealthChecks *struct {
		HTTP int `json:"http,omitempty"`
		GUE  int `json:"gue,omitempty"`
	}
}

type Services *struct {
	Name     string `json:"name"`
	HashKey  string `json:"hash_key"`
	Seed     string `json:"seed"`
	Binds    []Binds `json:"binds"`
	Backends []Backends `json:"backends"`
}

type Forwarding struct {
	Services []Services `json:"services"`
}

type Application struct {
	Config				*Config
	Arguments			map[string]interface{}
	BalancerProgram		*ebpf.Program
	DummyProgram		*ebpf.Program
	Collection			*ebpf.Collection
	ForwardingFile		Forwarding
	BindBackendsMapSpec	*ebpf.MapSpec
}

func loadJSONFile(filename string, target interface{}) error {
	bytes, err := ioutil.ReadFile(filename)
	assertExit(err)

	err = json.Unmarshal(bytes, &target)
	assertExit(err)

	return nil
}

func (app *Application) SyncConfigMap() error {
	configMap := app.Collection.Maps["config"]
	if configMap == nil {
		return errors.New("config map not found")
	}

	// 0: number of table colums
	configKey := uint32(0)
	collumns := app.Config.NumberOfCollumns
	if collumns == 0 {
		return errors.New("number of table collumns invalid")
	}
	fmt.Printf("Got number of collumns in table: %v\n", app.Config.NumberOfCollumns)
	err := configMap.Put(configKey, collumns)
	if err != nil {
		return err
	}

	// 1/2: hashing key halves
	configKey = uint32(1)
	if len(app.Config.HashingKey) < 16 || len(app.Config.HashingKey) > 16 {
		return errors.New("hashing key invalid")
	}
	fmt.Printf("Got hashing key: %v\n", app.Config.HashingKey)
	hashingKey1 := []byte(app.Config.HashingKey[:8])
	hashingKey2 := []byte(app.Config.HashingKey[8:16])

	err = configMap.Put(configKey, hashingKey1)
	if err != nil {
		return err
	}

	configKey = uint32(2)
	err = configMap.Put(configKey, hashingKey2)
	if err != nil {
		return err
	}

	return nil
}

func (app *Application) SyncServices() error {
	for i, service := range app.ForwardingFile.Services {
		i := uint32(i)

		err := app.syncBindsMap(i, service)
		if err != nil {
			return err
		}
		// syncFowardingMap is called from syncBindsMap
	}
	return nil
}

func (app *Application) syncBindsMap(serviceIndex uint32, service Services) error {
	bindsMap := app.Collection.Maps["binds"]
	if bindsMap == nil {
		return errors.New("binds map not found")
	}

	err := app.syncForwardingMap(service.Backends, serviceIndex, service.Seed)
	assertExit(err)

	for i := uint32(0); i < uint32(len(service.Binds)); i++ {
		err, proto := GetProtocolNumber(service.Binds[i].Protocol)
		assertExit(err)
		bindRowKey := BindsRowKey{
			IPAddress: Pack32BinaryIP4(service.Binds[i].IPAddress),
			Port: service.Binds[i].Port,
			Protocol: proto,
		}

		buf := &bytes.Buffer{}
		err = binary.Write(buf, binary.BigEndian, bindRowKey)
		assertExit(err)

		keySlice := app.GetHashingKeySlice()
		keyHalf1 := binary.LittleEndian.Uint64([]byte(keySlice[0]))
		keyHalf2 := binary.LittleEndian.Uint64([]byte(keySlice[1]))
		hash := siphash.Hash(keyHalf1, keyHalf2, buf.Bytes())
		if hash == 0 {
			return errors.New("could not hash bind")
		}

		// write hash to key in map with leading byte first
		b := make([]byte, 8)
		binary.BigEndian.PutUint64(b, hash)

		err = bindsMap.Put(b, i)
		assertExit(err)
		err = app.syncHashKeysMap(hash, service.HashKey)
		assertExit(err)
	}

	return nil
}

func (app *Application) syncHashKeysMap(key uint64, hashKeyString string) error {
	HashKeysMap := app.Collection.Maps["hash_keys"]
	if HashKeysMap == nil {
		return errors.New("hash_keys map not found")
	}

	hashKeyHex, err := hex.DecodeString(hashKeyString)
	if err != nil {
		return fmt.Errorf("could not decode hashkey: %s", hashKeyString)
	}
	
	hashKeyBytes := make([]byte, 8)
	copy(hashKeyBytes[:], hashKeyHex[:8])

	err = HashKeysMap.Put(key, hashKeyBytes)
	if err != nil {
		return err
	}

	return nil
}

/*
 * Theres a lot of funny stuff happening here. Basically, the idea is we want to create a table
 * (65k) where all the backends associated with bind(s) are. This table contains the other 
 * 'second-chance' servers as well. We choose these second chance servers using the
 * rendevous algoritm, which basically entains hashing each server with the service hash key
 * and the server IP, this creates a blake3 32 byte long weight. We pick the largest three
 * weights and in doing so create a randomised table. There will be duplicate rows, thats a
 * non-issue.
 // TODO update this comment
 */
func (app *Application) syncForwardingMap(backends []Backends, index uint32, seed string) (error) {
	bindBackendsMap := app.Collection.Maps["bind_backends"]
	if bindBackendsMap == nil {
		return errors.New("bind_backends map not found")
	}

	// Create the map thats to be saved to bind_backends
	mapName := fmt.Sprintf("backends_%d", index)
	mapSpec := app.BindBackendsMapSpec.Copy()
	mapSpec.Name = mapName
	newMap, err := ebpf.NewMap(mapSpec)
	assertExit(err)

	/*checkedBackends := make(map[string]uint32, len(backends))
	for backend := range(backends) {

	}*/

	// generate the IPs for each row in the table
	for x := uint32(0); x < 65536; x++ {
		type weightsStruct struct {
			BackendsArrayIndex int
			WeightHash []byte
		}
		weights := []weightsStruct{}

		keySlice := app.GetHashingKeySlice()
		keyHalf1 := binary.LittleEndian.Uint64([]byte(keySlice[0]))
		keyHalf2 := binary.LittleEndian.Uint64([]byte(keySlice[1]))

		row_seed := siphash.Hash(keyHalf1, keyHalf2, []byte(strconv.Itoa(int(x)) + seed))
		if row_seed == 0 {
			return errors.New("could not hash row seed")
		}

		row_seed_bytes := make([]byte, 8)
		binary.BigEndian.PutUint64(row_seed_bytes, row_seed)
		for y, backend := range backends {
			weightHash := siphash.Hash(keyHalf1, keyHalf2, append([]byte(backend.IPAddress), row_seed_bytes...))
			// write hash to key in map with leading byte first
			weightHashBytes := make([]byte, 8)
			binary.BigEndian.PutUint64(weightHashBytes, weightHash)
			if weightHash == 0 {
				return errors.New("could not hash weight")
			}
			w := weightsStruct{BackendsArrayIndex: y, WeightHash: weightHashBytes}
			weights = append(weights, w)
		}

		sort.SliceStable(weights, func(i, j int) bool {
			// keep looping till we find which has the larger byte
			for y := 0; i < 32; i++ {
				iHex := int(weights[i].WeightHash[y:y+1][0])
				jHex := int(weights[j].WeightHash[y:y+1][0])
				if iHex < jHex {
					return true
				} else if jHex < iHex {
					return false
				}
			}
			return false
		})

		// Get the top 3 best weighted servers out of all the backends for this bind
		bestBackends := weights[0:app.Config.NumberOfCollumns]

		row := make([]uint32, app.Config.NumberOfCollumns+1)

		ips := make([]uint32, app.Config.NumberOfCollumns)
		for bb := uint32(0); bb < uint32(len(bestBackends)); bb++ {
			// get the interface id that the first backend is reachable on
			if bb == 0 {
				row[0] = backends[bestBackends[bb].BackendsArrayIndex].InterfaceID
			}
			ips[bb] = Pack32BinaryIP4(backends[bestBackends[bb].BackendsArrayIndex].IPAddress)
		}

		copy(row[1:], ips[0:])
		assertExit(newMap.Put(x, row))
	}

	assertExit(bindBackendsMap.Put(index, newMap))

	return nil
}

func (app *Application) GetHashingKeySlice() []string {
	keySlice := make([]string, 2)
	keySlice[0] = app.Config.HashingKey[0:8]
	keySlice[1] = app.Config.HashingKey[8:16]
	return keySlice
}

func IP4toInt(IPv4Address net.IP) int64 {
	IPv4Int := big.NewInt(0)
	IPv4Int.SetBytes(IPv4Address.To4())
	return IPv4Int.Int64()
}

func Pack32BinaryIP4(ip4Address string) uint32 {
	ipv4Decimal := IP4toInt(net.ParseIP(ip4Address))

	buf := new(bytes.Buffer)
	err := binary.Write(buf, binary.BigEndian, uint32(ipv4Decimal))

	if err != nil {
		fmt.Println("Unable to write to buffer:", err)
	}

	return binary.LittleEndian.Uint32(buf.Bytes())
}

func assertExit(err error) {
	if err != nil {
		panic(err)
	}
}

func GetProtocolNumber(protocol string) (error, uint8) {
	switch protocol {
	case "tcp":
		return nil, uint8(6)
	case "udp":
		return nil, uint8(17)
	default:
		return errors.New("could not determine protocol number"), uint8(0)
	}
}

func main() {
	usage := `Load Balancer CLI

	Usage:
	  load-balancer CONFIG-FILE FORWARDING-FILE BPF-OBJECT-FILE BPF-BALANCER-PROGRAM-NAME BPF-DUMMY-PROGRAM-NAME INTERFACE-NAME [-d | --debug]
	  load-balancer -h | --help

	Arguments:
	  CONFIG-FILE				JSON configuration file location
	  FORWARDING-FILE			JSON forwarding file location
	  BPF-OBJECT-FILE			BPF object location
	  BPF-BALANCER-PROGRAM-NAME	BPF balancer program name
	  BPF-DUMMY-PROGRAM-NAME	BPF dummy program name
	  INTERFACE-NAME			Interface name e.g. enp0s9
	
	Options:
	  -h  --help		Show this screen.
	  -d  --debug		Enable additional debug output, useful during testing.
	`

	arguments, err := docopt.ParseArgs(usage, nil, "Load Balancer XDP v0")
	assertExit(err)

	// TODO need to verify all args
	configFileString := arguments["CONFIG-FILE"].(string)
	forwardingFileString := arguments["FORWARDING-FILE"].(string)
	programFileString := arguments["BPF-OBJECT-FILE"].(string)
	balancerProgramNameString := arguments["BPF-BALANCER-PROGRAM-NAME"].(string)
	dummyProgramNameString := arguments["BPF-DUMMY-PROGRAM-NAME"].(string)
	//interfaceNameString := arguments["INTERFACE-NAME"].(string)

	cfg := Config{}
	assertExit(loadJSONFile(configFileString, &cfg))

	assertExit(rlimit.RemoveMemlock())

	spec, err := ebpf.LoadCollectionSpec(programFileString)
	assertExit(err)

	// inject the template
	// We want the value size to be 4 * number of collumns+1 because
	// we want the first server to have the ifindex of the ethernet device
	// we plan on sending the packet over.
	// 1st 4 bytes: ethernet index for first IP
	// Rest of bytes: IPs
	bindBackendsTemplateSpec := &ebpf.MapSpec{
		Type:       ebpf.Array,
		KeySize:    4,
		ValueSize: 	4 * (uint32(cfg.NumberOfCollumns)+1),
		MaxEntries: 0x10000,
	}
	bindBackendsMapSpec, ok := spec.Maps["bind_backends"]
	if !ok {
		panic("no map named bind_backends found")
	}
	bindBackendsMapSpec.InnerMap = bindBackendsTemplateSpec

	coll, err := ebpf.NewCollection(spec)
	assertExit(err)
	defer coll.Close()

	balancerProgram := coll.Programs[balancerProgramNameString]
	if balancerProgram == nil {
		panic("eBPF balancer program not found")
	}

	dummyProgram := coll.Programs[dummyProgramNameString]
	if dummyProgram == nil {
		panic("eBPF dummy program not found")
	}

	// -----------------------------------

	forwardingFileJSON := Forwarding{}
	loadJSONFile(forwardingFileString, &forwardingFileJSON)

	app := &Application{
		Config:        			&cfg,
		Collection:     		coll,
		Arguments:				arguments,
		BalancerProgram:		balancerProgram,
		DummyProgram:			dummyProgram,
		ForwardingFile:			forwardingFileJSON,
		BindBackendsMapSpec:	bindBackendsTemplateSpec,
	}

	assertExit(app.SyncConfigMap())
	assertExit(app.SyncServices())

	txPortsMap := app.Collection.Maps["tx_ports"]
	if txPortsMap == nil {
		fmt.Errorf("tx_ports map not found")
	}

	// Attach the main program to the interface specified in the arguments passed
	link, err := netlink.LinkByName(app.Arguments["INTERFACE-NAME"].(string))
	assertExit(err)
	assertExit(netlink.LinkSetXdpFd(link, app.BalancerProgram.FD()))
	defer (func() { assertExit(netlink.LinkSetXdpFd(link, -1)) })()

	linksAddedTo := []uint32{}
	for _, service := range app.ForwardingFile.Services {
		for _, backend := range(service.Backends) {
			// Link the dummy program to the link specified for the backend but only it hasn't been doing already
			var contains bool = false
			for _, x := range linksAddedTo {
				if x == backend.InterfaceID {
					contains = true
					break
				}
			}
			if contains || uint32(link.Attrs().Index) == backend.InterfaceID {
				break
			}
			
			interfaceID := backend.InterfaceID
			linksAddedTo = append(linksAddedTo, interfaceID)
			
			dummyLink, err := netlink.LinkByIndex(int(interfaceID))
			assertExit(err)
			assertExit(netlink.LinkSetXdpFd(dummyLink, app.DummyProgram.FD()))
			defer (func() { assertExit(netlink.LinkSetXdpFd(dummyLink, -1)) })()

			// Add the interface index to the viable interfaces that can be used for forwarding
			b := make([]byte, 4)
			binary.LittleEndian.PutUint32(b, interfaceID)
			interfaceID = binary.LittleEndian.Uint32(b)
			assertExit(txPortsMap.Put(interfaceID, interfaceID))
		}
	}

	// -----------------------------------

	print("   Running on interface\n")

	quit := make(chan os.Signal)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	print(" Stopping ...\n")
}
