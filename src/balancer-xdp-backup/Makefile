xdp_balancer: xdp_balancer.o
	#bpftool net detach xdpdrv dev enp0s9
	#rm -f /sys/fs/bpf/xdp_balancer
	#bpftool prog load xdp_balancer.o /sys/fs/bpf/xdp_balancer
	#bpftool net attach xdpdrv pinned /sys/fs/bpf/xdp_balancer dev enp0s9

xdp_balancer.o: xdp_balancer.c
	gcc -c blake3.c blake3_dispatch.c blake3_portable.c blake3_sse2_x86-64_unix.S blake3_sse41_x86-64_unix.S blake3_avx2_x86-64_unix.S blake3_avx512_x86-64_unix.S
	ar cr libblake.a blake3.o blake3_dispatch.o blake3_portable.o blake3_sse2_x86-64_unix.o blake3_sse41_x86-64_unix.o blake3_avx2_x86-64_unix.o blake3_avx512_x86-64_unix.o
	rm blake3.o blake3_dispatch.o blake3_portable.o blake3_sse2_x86-64_unix.o blake3_sse41_x86-64_unix.o blake3_avx2_x86-64_unix.o blake3_avx512_x86-64_unix.o
	clang -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    -I../../lib/libbpf/src\
	    -lblake3 \
	    -std=gnu11 \
	    -Wall \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -O2 -emit-llvm -c -g -o ${@:.o=.ll} $<
	llc -march=bpf -filetype=obj -o $@ ${@:.o=.ll}

#	    -Wunused-but-set-variable
#	    -Werror
#	    -Wno-unused-value

clean:
	#bpftool net detach xdpdrv dev enp0s9
	rm -f /sys/fs/bpf/xdp_balancer
	rm xdp_balancer.o
	rm xdp_balancer.ll
