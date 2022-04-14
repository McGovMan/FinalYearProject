package main

import (
	"fmt"
	"encoding/binary"
	"github.com/dchest/siphash"
	"encoding/hex"
)

func main() {
	keyHalf1 := binary.LittleEndian.Uint64([]byte("nocyrptk"))
	keyHalf2 := binary.LittleEndian.Uint64([]byte("eyneeded"))
	//keyHalf1 := binary.BigEndian.Uint64([]byte{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
    //keyHalf2 := binary.BigEndian.Uint64([]byte{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00})
	bytes := []byte{ 0x05, 0xd8, 0xa8, 0xc0, 0x00, 0x50, 0x06 }
	//bytes := []byte{ 0x31, 0x39, 0x32, 0x2e, 0x31, 0x36, 0x38, 0x2e, 0x32, 0x31, 0x36, 0x2e, 0x35 }
	sum1 := siphash.Hash(keyHalf1, keyHalf2, bytes)
	fmt.Printf("key: %x%x\n", keyHalf1, keyHalf2)
	fmt.Printf("bytes to be hashed: %s\n", hex.EncodeToString(bytes))
	fmt.Printf("hash: %x\n", sum1)
}
