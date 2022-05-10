package main

import (
	"github.com/cilium/ebpf"
	"fmt"
)

type PacketStats struct {
	TotalPackets			uint64
	TotalPacketsDropped		uint64
	TotalPacketsAccepted	uint64
	TotalPacketsForwarded	uint64
	BytesReceived			uint64
}

func main() {
	packetStatsMap, err := ebpf.LoadPinnedMap("/sys/fs/bpf/packet_stats", nil)
	if err != nil {
		panic(err)
	}

	values := make([]PacketStats, 2)
	if err := packetStatsMap.Lookup(uint32(0), &values); err != nil {
		panic(err);
	}

	stats := PacketStats{
		TotalPackets: 0,
		TotalPacketsDropped: 0,
		TotalPacketsAccepted: 0,
		TotalPacketsForwarded: 0,
		BytesReceived: 0,
	}

	for _, v := range values {
		stats.TotalPackets += v.TotalPackets
		stats.TotalPacketsDropped += v.TotalPacketsDropped
		stats.TotalPacketsAccepted += v.TotalPacketsAccepted
		stats.TotalPacketsForwarded += v.TotalPacketsForwarded
		stats.BytesReceived += v.BytesReceived
	}

	fmt.Printf("Total Packets: %d\n", stats.TotalPackets)
	fmt.Printf("Total Packets Dropped: %d\n", stats.TotalPacketsDropped)
	fmt.Printf("Total Packets Accepted: %d\n", stats.TotalPacketsAccepted)
	fmt.Printf("Total Packets Forwarded: %d\n", stats.TotalPacketsForwarded)
	fmt.Printf("Total Bytes Received: %d\n", stats.BytesReceived)
}
