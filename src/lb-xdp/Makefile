xdp_balancer.o: xdp_balancer.c
	clang -S \
	    -target bpf \
	    -D __BPF_TRACING__ \
	    -I../../lib/libbpf/src\
	    -std=gnu11 \
	    -Wall \
	    -Wno-pointer-sign \
	    -Wno-compare-distinct-pointer-types \
	    -O2 -fPIC -emit-llvm -c -g -o ${@:.o=.ll} $<
	llc -march=bpf -filetype=obj -o $@ ${@:.o=.ll}


clean:
	rm -f /sys/fs/bpf/xdp_balancer
	rm xdp_balancer.o
	rm xdp_balancer.ll
