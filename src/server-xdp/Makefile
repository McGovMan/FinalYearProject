xdp_decapsulator: xdp_decapsulator.o
	sudo arptables -A INPUT -d 192.168.216.5 -j DROP
	bpftool prog load xdp_decapsulator.o /sys/fs/bpf/xdp_decapsulator
	bpftool net attach xdpgeneric pinned /sys/fs/bpf/xdp_decapsulator dev enp0s9

xdp_decapsulator.o: xdp_decapsulator.c
	clang -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    -I../../lib/libbpf/src\
	    -std=gnu11 \
	    -Wall \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -O2 -emit-llvm -c -o ${@:.o=.ll} $<
	llc -march=bpf -filetype=obj -o $@ ${@:.o=.ll}

#	    -Wunused-but-set-variable
#	    -Werror
#	    -Wno-unused-value

clean:
	bpftool net detach xdpgeneric dev enp0s9
	rm -f /sys/fs/bpf/xdp_decapsulator
	rm xdp_decapsulator.o
	rm xdp_decapsulator.ll
	sudo arptables -A INPUT -d 192.168.216.5 -j DROP
