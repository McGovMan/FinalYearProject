; ModuleID = 'xdp_balancer.c'
source_filename = "xdp_balancer.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.bpf_map_def = type { i32, i32, i32, i32, i32 }
%struct.xdp_md = type { i32, i32, i32, i32, i32, i32 }
%struct.binds_row_key = type <{ i32, i16, i8 }>
%struct.bpf_fib_lookup = type { i8, i8, i16, i16, %union.anon.1, i32, %union.anon.2, %union.anon.3, %union.anon.4, i16, i16, [6 x i8], [6 x i8] }
%union.anon.1 = type { i16 }
%union.anon.2 = type { i32 }
%union.anon.3 = type { [4 x i32] }
%union.anon.4 = type { [4 x i32] }
%struct.iphdr = type { i8, i8, i16, i16, i16, i8, i8, i16, i32, i32 }
%struct.tcphdr = type { i16, i16, i32, i32, i16, i16, i16, i16 }
%struct.udphdr = type { i16, i16, i16, i16 }
%struct.packet_context = type { i8*, i8*, i32*, i16, i16, %struct.iphdr*, %struct.ipv6hdr*, %struct.ethhdr*, i32, %struct.iphdr*, %struct.lb_gue_hdr*, %struct.udphdr* }
%struct.ipv6hdr = type { i8, [3 x i8], i16, i8, i8, %struct.in6_addr, %struct.in6_addr }
%struct.in6_addr = type { %union.anon }
%union.anon = type { [4 x i32] }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }
%struct.lb_gue_hdr = type { i8, i8, i16, i16, i8, i8, [2 x i32] }

@tx_ports = global %struct.bpf_map_def { i32 14, i32 4, i32 4, i32 64, i32 0 }, section "maps", align 4, !dbg !0
@config = global %struct.bpf_map_def { i32 2, i32 4, i32 8, i32 4, i32 0 }, section "maps", align 4, !dbg !166
@binds = global %struct.bpf_map_def { i32 1, i32 8, i32 4, i32 4096, i32 0 }, section "maps", align 4, !dbg !177
@bind_backends = global %struct.bpf_map_def { i32 12, i32 4, i32 0, i32 4096, i32 0 }, section "maps", align 4, !dbg !179
@hash_keys = global %struct.bpf_map_def { i32 1, i32 8, i32 8, i32 4096, i32 0 }, section "maps", align 4, !dbg !181
@source_mac = local_unnamed_addr global [6 x i8] c"\08\00'\9B\E4\F5", align 1, !dbg !183
@gateway_mac = local_unnamed_addr global [6 x i8] c"\0A\00'\00\00\16", align 1, !dbg !186
@__const.balancer.____fmt = private unnamed_addr constant [10 x i8] c"Dia Dhuit\00", align 1
@_license = global [4 x i8] c"GPL\00", section "license", align 1, !dbg !188
@__const.process_packet.____fmt = private unnamed_addr constant [35 x i8] c"Congrats, your packet was accepted\00", align 1
@llvm.compiler.used = appending global [8 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @balancer to i8*), i8* bitcast (%struct.bpf_map_def* @bind_backends to i8*), i8* bitcast (%struct.bpf_map_def* @binds to i8*), i8* bitcast (%struct.bpf_map_def* @config to i8*), i8* bitcast (%struct.bpf_map_def* @hash_keys to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @pass to i8*), i8* bitcast (%struct.bpf_map_def* @tx_ports to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define i32 @balancer(%struct.xdp_md* %0) #0 section "xdp_balancer" !dbg !337 {
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  %4 = alloca %struct.binds_row_key, align 4
  %5 = alloca i32, align 4
  %6 = alloca [35 x i8], align 1
  %7 = alloca i64, align 8
  %8 = alloca i32, align 4
  %9 = alloca %struct.bpf_fib_lookup, align 4
  %10 = alloca [10 x i8], align 1
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !341, metadata !DIExpression()), !dbg !347
  %11 = getelementptr inbounds [10 x i8], [10 x i8]* %10, i64 0, i64 0, !dbg !348
  call void @llvm.lifetime.start.p0i8(i64 10, i8* nonnull %11) #10, !dbg !348
  call void @llvm.dbg.declare(metadata [10 x i8]* %10, metadata !342, metadata !DIExpression()), !dbg !348
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(10) %11, i8* noundef nonnull align 1 dereferenceable(10) getelementptr inbounds ([10 x i8], [10 x i8]* @__const.balancer.____fmt, i64 0, i64 0), i64 10, i1 false), !dbg !348
  %12 = call i64 (i8*, i32, ...) inttoptr (i64 6 to i64 (i8*, i32, ...)*)(i8* nonnull %11, i32 10) #10, !dbg !348
  call void @llvm.lifetime.end.p0i8(i64 10, i8* nonnull %11) #10, !dbg !349
  call void @llvm.dbg.value(metadata %struct.xdp_md* %0, metadata !350, metadata !DIExpression()) #10, !dbg !448
  call void @llvm.dbg.value(metadata i32 1, metadata !359, metadata !DIExpression()) #10, !dbg !448
  %13 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0, !dbg !450
  %14 = load i32, i32* %13, align 4, !dbg !450, !tbaa !451
  %15 = zext i32 %14 to i64, !dbg !456
  %16 = inttoptr i64 %15 to i8*, !dbg !457
  call void @llvm.dbg.value(metadata i8* %16, metadata !360, metadata !DIExpression()) #10, !dbg !448
  %17 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1, !dbg !458
  %18 = load i32, i32* %17, align 4, !dbg !458, !tbaa !459
  %19 = zext i32 %18 to i64, !dbg !460
  call void @llvm.dbg.value(metadata i64 %19, metadata !361, metadata !DIExpression()) #10, !dbg !448
  call void @llvm.dbg.value(metadata i8* %16, metadata !362, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)) #10, !dbg !448
  %20 = getelementptr i8, i8* %16, i64 34, !dbg !461
  %21 = bitcast i8* %20 to %struct.iphdr*, !dbg !461
  %22 = inttoptr i64 %19 to %struct.iphdr*, !dbg !463
  %23 = icmp ugt %struct.iphdr* %21, %22, !dbg !464
  br i1 %23, label %202, label %24, !dbg !465

24:                                               ; preds = %1
  %25 = getelementptr i8, i8* %16, i64 23, !dbg !466
  %26 = load i8, i8* %25, align 1, !dbg !466, !tbaa !467
  switch i8 %26, label %202 [
    i8 6, label %27
    i8 17, label %32
  ], !dbg !470

27:                                               ; preds = %24
  call void @llvm.dbg.value(metadata i8* %16, metadata !364, metadata !DIExpression(DW_OP_plus_uconst, 34, DW_OP_stack_value)) #10, !dbg !471
  %28 = getelementptr i8, i8* %16, i64 54, !dbg !472
  %29 = bitcast i8* %28 to %struct.tcphdr*, !dbg !472
  %30 = inttoptr i64 %19 to %struct.tcphdr*, !dbg !474
  %31 = icmp ugt %struct.tcphdr* %29, %30, !dbg !475
  br i1 %31, label %202, label %37, !dbg !476

32:                                               ; preds = %24
  call void @llvm.dbg.value(metadata i8* %16, metadata !388, metadata !DIExpression(DW_OP_plus_uconst, 34, DW_OP_stack_value)) #10, !dbg !477
  %33 = getelementptr i8, i8* %16, i64 42, !dbg !478
  %34 = bitcast i8* %33 to %struct.udphdr*, !dbg !478
  %35 = inttoptr i64 %19 to %struct.udphdr*, !dbg !480
  %36 = icmp ugt %struct.udphdr* %34, %35, !dbg !481
  br i1 %36, label %202, label %37, !dbg !482

37:                                               ; preds = %32, %27
  %38 = getelementptr i8, i8* %16, i64 36, !dbg !483
  %39 = bitcast i8* %38 to i16*, !dbg !483
  %40 = load i16, i16* %39, align 2, !dbg !483
  call void @llvm.dbg.value(metadata i16 %40, metadata !363, metadata !DIExpression()) #10, !dbg !448
  %41 = bitcast %struct.binds_row_key* %4 to i8*, !dbg !484
  call void @llvm.lifetime.start.p0i8(i64 7, i8* nonnull %41) #10, !dbg !484
  call void @llvm.dbg.declare(metadata %struct.binds_row_key* %4, metadata !391, metadata !DIExpression()) #10, !dbg !485
  %42 = getelementptr inbounds %struct.binds_row_key, %struct.binds_row_key* %4, i64 0, i32 0, !dbg !486
  %43 = getelementptr i8, i8* %16, i64 30, !dbg !487
  %44 = bitcast i8* %43 to i32*, !dbg !487
  %45 = load i32, i32* %44, align 4, !dbg !487, !tbaa !488
  call void @llvm.dbg.value(metadata i32 %45, metadata !489, metadata !DIExpression()) #10, !dbg !495
  %46 = call i32 @llvm.bswap.i32(i32 %45) #10, !dbg !497
  store i32 %46, i32* %42, align 4, !dbg !486, !tbaa !498
  %47 = getelementptr inbounds %struct.binds_row_key, %struct.binds_row_key* %4, i64 0, i32 1, !dbg !486
  store i16 %40, i16* %47, align 4, !dbg !486, !tbaa !500
  %48 = getelementptr inbounds %struct.binds_row_key, %struct.binds_row_key* %4, i64 0, i32 2, !dbg !486
  store i8 %26, i8* %48, align 2, !dbg !486, !tbaa !501
  %49 = bitcast i32* %5 to i8*, !dbg !502
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %49) #10, !dbg !502
  call void @llvm.dbg.value(metadata %struct.binds_row_key* %4, metadata !503, metadata !DIExpression()) #10, !dbg !515
  call void @llvm.dbg.value(metadata i64 7742937296321867630, metadata !510, metadata !DIExpression()) #10, !dbg !515
  call void @llvm.dbg.value(metadata i64 7234298763096783205, metadata !511, metadata !DIExpression()) #10, !dbg !515
  %50 = bitcast i64* %2 to i8*, !dbg !517
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %50) #10, !dbg !517
  call void @llvm.dbg.value(metadata i64* %2, metadata !512, metadata !DIExpression(DW_OP_deref)) #10, !dbg !515
  call fastcc void @siphash(i8* nonnull %41, i64 7, i8* nonnull %50) #10, !dbg !518
  %51 = bitcast i64* %3 to i8*, !dbg !519
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %51) #10, !dbg !519
  %52 = load i64, i64* %2, align 8, !dbg !520, !tbaa !521
  call void @llvm.dbg.value(metadata i64 %52, metadata !512, metadata !DIExpression()) #10, !dbg !515
  call void @llvm.dbg.value(metadata i64 %52, metadata !523, metadata !DIExpression()) #10, !dbg !528
  %53 = call i64 @llvm.bswap.i64(i64 %52) #10, !dbg !530
  call void @llvm.dbg.value(metadata i64 %53, metadata !513, metadata !DIExpression()) #10, !dbg !515
  store i64 %53, i64* %3, align 8, !dbg !531, !tbaa !521
  call void @llvm.dbg.value(metadata i64* %3, metadata !513, metadata !DIExpression(DW_OP_deref)) #10, !dbg !515
  %54 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @binds to i8*), i8* nonnull %51) #10, !dbg !532
  call void @llvm.dbg.value(metadata i8* %54, metadata !514, metadata !DIExpression()) #10, !dbg !515
  %55 = icmp eq i8* %54, null, !dbg !533
  br i1 %55, label %56, label %57, !dbg !535

56:                                               ; preds = %37
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %51) #10, !dbg !536
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %50) #10, !dbg !536
  call void @llvm.dbg.value(metadata i32 %59, metadata !398, metadata !DIExpression()) #10, !dbg !448
  br label %200, !dbg !537

57:                                               ; preds = %37
  %58 = bitcast i8* %54 to i32*, !dbg !532
  call void @llvm.dbg.value(metadata i32* %58, metadata !514, metadata !DIExpression()) #10, !dbg !515
  %59 = load i32, i32* %58, align 4, !dbg !538, !tbaa !539
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %51) #10, !dbg !536
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %50) #10, !dbg !536
  call void @llvm.dbg.value(metadata i32 %59, metadata !398, metadata !DIExpression()) #10, !dbg !448
  store i32 %59, i32* %5, align 4, !dbg !540, !tbaa !539
  %60 = icmp eq i32 %59, -1, !dbg !541
  br i1 %60, label %200, label %61, !dbg !537

61:                                               ; preds = %57
  %62 = getelementptr inbounds [35 x i8], [35 x i8]* %6, i64 0, i64 0, !dbg !543
  call void @llvm.lifetime.start.p0i8(i64 35, i8* nonnull %62) #10, !dbg !543
  call void @llvm.dbg.declare(metadata [35 x i8]* %6, metadata !399, metadata !DIExpression()) #10, !dbg !543
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(35) %62, i8* noundef nonnull align 1 dereferenceable(35) getelementptr inbounds ([35 x i8], [35 x i8]* @__const.process_packet.____fmt, i64 0, i64 0), i64 35, i1 false) #10, !dbg !543
  %63 = call i64 (i8*, i32, ...) inttoptr (i64 6 to i64 (i8*, i32, ...)*)(i8* nonnull %62, i32 35) #10, !dbg !543
  call void @llvm.lifetime.end.p0i8(i64 35, i8* nonnull %62) #10, !dbg !544
  call void @llvm.dbg.value(metadata %struct.packet_context* poison, metadata !404, metadata !DIExpression()) #10, !dbg !448
  %64 = load i32, i32* %13, align 4, !dbg !545, !tbaa !451
  %65 = zext i32 %64 to i64, !dbg !546
  %66 = load i32, i32* %17, align 4, !dbg !547, !tbaa !459
  %67 = zext i32 %66 to i64, !dbg !548
  %68 = inttoptr i64 %67 to i8*, !dbg !549
  call void @llvm.dbg.value(metadata %struct.packet_context* poison, metadata !550, metadata !DIExpression()) #10, !dbg !560
  %69 = inttoptr i64 %65 to %struct.ethhdr*, !dbg !562
  call void @llvm.dbg.value(metadata %struct.ethhdr* %69, metadata !555, metadata !DIExpression()) #10, !dbg !560
  %70 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %69, i64 1, i32 0, i64 0, !dbg !564
  %71 = icmp ugt i8* %70, %68, !dbg !564
  br i1 %71, label %200, label %72, !dbg !562

72:                                               ; preds = %61
  %73 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %69, i64 0, i32 2, !dbg !566
  %74 = load i16, i16* %73, align 1, !dbg !566, !tbaa !567
  %75 = call i16 @llvm.bswap.i16(i16 %74) #10, !dbg !566
  switch i16 %75, label %200 [
    i16 2054, label %82
    i16 2048, label %76
    i16 -31011, label %79
  ], !dbg !569

76:                                               ; preds = %72
  call void @llvm.dbg.value(metadata %struct.ethhdr* %69, metadata !559, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)) #10, !dbg !560
  %77 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %69, i64 0, i32 0, i64 34, !dbg !570
  %78 = icmp ugt i8* %77, %68, !dbg !570
  br i1 %78, label %200, label %82, !dbg !574

79:                                               ; preds = %72
  call void @llvm.dbg.value(metadata %struct.ethhdr* %69, metadata !558, metadata !DIExpression(DW_OP_plus_uconst, 14, DW_OP_stack_value)) #10, !dbg !560
  %80 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %69, i64 0, i32 0, i64 54, !dbg !575
  %81 = icmp ugt i8* %80, %68, !dbg !575
  br i1 %81, label %200, label %82, !dbg !578

82:                                               ; preds = %79, %76, %72
  call void @llvm.dbg.value(metadata i32 0, metadata !422, metadata !DIExpression()) #10, !dbg !448
  %83 = call i64 inttoptr (i64 44 to i64 (%struct.xdp_md*, i32)*)(%struct.xdp_md* nonnull %0, i32 -44) #10, !dbg !579
  %84 = trunc i64 %83 to i32, !dbg !579
  call void @llvm.dbg.value(metadata i32 %84, metadata !422, metadata !DIExpression()) #10, !dbg !448
  %85 = icmp eq i32 %84, -1, !dbg !580
  br i1 %85, label %200, label %86, !dbg !582

86:                                               ; preds = %82
  %87 = load i32, i32* %13, align 4, !dbg !583, !tbaa !451
  %88 = zext i32 %87 to i64, !dbg !584
  %89 = inttoptr i64 %88 to i8*, !dbg !585
  %90 = load i32, i32* %17, align 4, !dbg !586, !tbaa !459
  %91 = zext i32 %90 to i64, !dbg !587
  %92 = inttoptr i64 %91 to i8*, !dbg !588
  %93 = inttoptr i64 %88 to %struct.ethhdr*, !dbg !589
  %94 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %93, i64 1, !dbg !591
  %95 = getelementptr %struct.ethhdr, %struct.ethhdr* %94, i64 0, i32 0, i64 0, !dbg !591
  %96 = icmp ugt i8* %95, %92, !dbg !591
  br i1 %96, label %200, label %97, !dbg !589

97:                                               ; preds = %86
  %98 = inttoptr i64 %91 to %struct.ethhdr*, !dbg !593
  %99 = icmp ugt %struct.ethhdr* %94, %98, !dbg !595
  br i1 %99, label %200, label %100, !dbg !596

100:                                              ; preds = %97
  %101 = getelementptr inbounds i8, i8* %89, i64 14, !dbg !597
  %102 = getelementptr inbounds i8, i8* %89, i64 34, !dbg !599
  %103 = icmp ugt i8* %102, %92, !dbg !599
  br i1 %103, label %200, label %104, !dbg !597

104:                                              ; preds = %100
  %105 = getelementptr inbounds i8, i8* %89, i64 42, !dbg !601
  %106 = icmp ugt i8* %105, %92, !dbg !601
  %107 = bitcast i8* %102 to i64*, !dbg !604
  br i1 %106, label %200, label %108, !dbg !604

108:                                              ; preds = %104
  %109 = getelementptr inbounds i8, i8* %89, i64 58, !dbg !605
  %110 = icmp ugt i8* %109, %92, !dbg !605
  %111 = bitcast i8* %105 to i64*, !dbg !608
  %112 = getelementptr inbounds i8, i8* %89, i64 78
  %113 = icmp ugt i8* %112, %92
  %114 = select i1 %110, i1 true, i1 %113, !dbg !608
  br i1 %114, label %200, label %115, !dbg !608

115:                                              ; preds = %108
  call void @llvm.dbg.value(metadata i64 7742937296321867630, metadata !423, metadata !DIExpression()) #10, !dbg !448
  call void @llvm.dbg.value(metadata i64 7234298763096783205, metadata !424, metadata !DIExpression()) #10, !dbg !448
  %116 = bitcast i64* %7 to i8*, !dbg !609
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %116) #10, !dbg !609
  call void @llvm.dbg.value(metadata i32* %5, metadata !610, metadata !DIExpression()) #10, !dbg !616
  %117 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @bind_backends to i8*), i8* nonnull %49) #10, !dbg !618
  call void @llvm.dbg.value(metadata i8* %117, metadata !615, metadata !DIExpression()) #10, !dbg !616
  call void @llvm.dbg.value(metadata i8* %117, metadata !426, metadata !DIExpression()) #10, !dbg !448
  %118 = icmp eq i8* %117, null, !dbg !619
  br i1 %118, label %198, label %119, !dbg !621

119:                                              ; preds = %115
  %120 = getelementptr inbounds i8, i8* %89, i64 70, !dbg !622
  call void @llvm.dbg.value(metadata i64* %7, metadata !425, metadata !DIExpression(DW_OP_deref)) #10, !dbg !448
  call fastcc void @siphash(i8* nonnull %120, i64 4, i8* nonnull %116) #10, !dbg !623
  %121 = bitcast i32* %8 to i8*, !dbg !624
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %121) #10, !dbg !624
  %122 = load i64, i64* %7, align 8, !dbg !625, !tbaa !521
  call void @llvm.dbg.value(metadata i64 %122, metadata !425, metadata !DIExpression()) #10, !dbg !448
  %123 = trunc i64 %122 to i32, !dbg !625
  %124 = and i32 %123, 65535, !dbg !625
  call void @llvm.dbg.value(metadata i32 %124, metadata !434, metadata !DIExpression()) #10, !dbg !448
  store i32 %124, i32* %8, align 4, !dbg !626, !tbaa !539
  call void @llvm.dbg.value(metadata i32* %8, metadata !434, metadata !DIExpression(DW_OP_deref)) #10, !dbg !448
  call void @llvm.dbg.value(metadata i8* %117, metadata !627, metadata !DIExpression()) #10, !dbg !634
  call void @llvm.dbg.value(metadata i32* %8, metadata !632, metadata !DIExpression()) #10, !dbg !634
  %125 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* nonnull %117, i8* nonnull %121) #10, !dbg !636
  call void @llvm.dbg.value(metadata i8* %125, metadata !633, metadata !DIExpression()) #10, !dbg !634
  call void @llvm.dbg.value(metadata i8* %125, metadata !435, metadata !DIExpression()) #10, !dbg !448
  %126 = icmp eq i8* %125, null, !dbg !637
  br i1 %126, label %196, label %127, !dbg !639

127:                                              ; preds = %119
  call void @llvm.dbg.value(metadata i8* %125, metadata !435, metadata !DIExpression()) #10, !dbg !448
  %128 = getelementptr inbounds i8, i8* %89, i64 30, !dbg !640
  %129 = bitcast i8* %128 to i32*, !dbg !640
  store i32 0, i32* %129, align 4, !dbg !640
  store i8 69, i8* %101, align 4, !dbg !641
  %130 = getelementptr inbounds i8, i8* %89, i64 15, !dbg !642
  store i8 0, i8* %130, align 1, !dbg !643, !tbaa !644
  %131 = sub i32 %90, %87, !dbg !645
  %132 = trunc i32 %131 to i16, !dbg !645
  %133 = add i16 %132, -14, !dbg !645
  %134 = call i16 @llvm.bswap.i16(i16 %133) #10
  %135 = getelementptr inbounds i8, i8* %89, i64 16, !dbg !646
  %136 = bitcast i8* %135 to i16*, !dbg !646
  store i16 %134, i16* %136, align 2, !dbg !647, !tbaa !648
  %137 = getelementptr inbounds i8, i8* %89, i64 18, !dbg !649
  %138 = bitcast i8* %137 to i16*, !dbg !649
  store i16 0, i16* %138, align 4, !dbg !650, !tbaa !651
  %139 = getelementptr inbounds i8, i8* %89, i64 20, !dbg !652
  %140 = bitcast i8* %139 to i16*, !dbg !652
  store i16 0, i16* %140, align 2, !dbg !653, !tbaa !654
  %141 = getelementptr inbounds i8, i8* %89, i64 22, !dbg !655
  store i8 -1, i8* %141, align 4, !dbg !656, !tbaa !657
  %142 = getelementptr inbounds i8, i8* %89, i64 23, !dbg !658
  store i8 17, i8* %142, align 1, !dbg !659, !tbaa !467
  %143 = getelementptr inbounds i8, i8* %89, i64 24, !dbg !660
  %144 = bitcast i8* %143 to i16*, !dbg !660
  store i16 0, i16* %144, align 2, !dbg !661, !tbaa !662
  %145 = getelementptr inbounds i8, i8* %89, i64 74, !dbg !663
  %146 = bitcast i8* %145 to i32*, !dbg !663
  %147 = load i32, i32* %146, align 4, !dbg !663, !tbaa !488
  %148 = getelementptr inbounds i8, i8* %89, i64 26, !dbg !664
  %149 = bitcast i8* %148 to i32*, !dbg !664
  store i32 %147, i32* %149, align 4, !dbg !665, !tbaa !666
  %150 = getelementptr inbounds i8, i8* %125, i64 4, !dbg !667
  %151 = bitcast i8* %150 to i32*, !dbg !667
  %152 = load i32, i32* %151, align 4, !dbg !667, !tbaa !539
  store i32 %152, i32* %129, align 4, !dbg !668, !tbaa !488
  %153 = call fastcc zeroext i16 @compute_ipv4_checksum(i8* nonnull %101) #10, !dbg !669
  store i16 %153, i16* %144, align 2, !dbg !670, !tbaa !662
  store i64 4062048797, i64* %107, align 2, !dbg !671
  %154 = add i16 %132, -34, !dbg !672
  %155 = call i16 @llvm.bswap.i16(i16 %154) #10
  %156 = getelementptr inbounds i8, i8* %89, i64 38, !dbg !673
  %157 = bitcast i8* %156 to i16*, !dbg !673
  store i16 %155, i16* %157, align 2, !dbg !674, !tbaa !675
  store i64 0, i64* %111, align 1, !dbg !677
  %158 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 0, !dbg !678
  call void @llvm.lifetime.start.p0i8(i64 64, i8* nonnull %158) #10, !dbg !678
  call void @llvm.dbg.declare(metadata %struct.bpf_fib_lookup* %9, metadata !445, metadata !DIExpression()) #10, !dbg !679
  %159 = bitcast i8* %125 to i32*, !dbg !680
  call void @llvm.memset.p0i8.i64(i8* noundef nonnull align 4 dereferenceable(64) %158, i8 0, i64 64, i1 false) #10, !dbg !681
  %160 = load i32, i32* %159, align 4, !dbg !680, !tbaa !539
  %161 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 5, !dbg !682
  store i32 %160, i32* %161, align 4, !dbg !683, !tbaa !684
  store i8 2, i8* %158, align 4, !dbg !686, !tbaa !687
  %162 = getelementptr inbounds i8, i8* %89, i64 59, !dbg !688
  %163 = load i8, i8* %162, align 1, !dbg !688, !tbaa !644
  %164 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 6, !dbg !689
  %165 = bitcast %union.anon.2* %164 to i8*, !dbg !689
  store i8 %163, i8* %165, align 4, !dbg !690, !tbaa !691
  %166 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 1, !dbg !692
  store i8 17, i8* %166, align 1, !dbg !693, !tbaa !694
  %167 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 2, !dbg !695
  store i16 0, i16* %167, align 2, !dbg !696, !tbaa !697
  %168 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 3, !dbg !698
  store i16 0, i16* %168, align 4, !dbg !699, !tbaa !700
  %169 = getelementptr inbounds i8, i8* %89, i64 60, !dbg !701
  %170 = bitcast i8* %169 to i16*, !dbg !701
  %171 = load i16, i16* %170, align 2, !dbg !701, !tbaa !648
  %172 = call i16 @llvm.bswap.i16(i16 %171) #10
  %173 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 4, i32 0, !dbg !702
  store i16 %172, i16* %173, align 2, !dbg !703, !tbaa !691
  %174 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 7, i32 0, i64 0, !dbg !704
  store i32 %147, i32* %174, align 4, !dbg !705, !tbaa !691
  %175 = load i32, i32* %151, align 4, !dbg !706, !tbaa !539
  %176 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 8, i32 0, i64 0, !dbg !707
  store i32 %175, i32* %176, align 4, !dbg !708, !tbaa !691
  %177 = bitcast %struct.xdp_md* %0 to i8*, !dbg !709
  %178 = call i64 inttoptr (i64 69 to i64 (i8*, %struct.bpf_fib_lookup*, i32, i32)*)(i8* %177, %struct.bpf_fib_lookup* nonnull %9, i32 64, i32 0) #10, !dbg !710
  %179 = trunc i64 %178 to i32, !dbg !710
  call void @llvm.dbg.value(metadata i32 %179, metadata !446, metadata !DIExpression()) #10, !dbg !448
  %180 = icmp eq i32 %179, 0, !dbg !711
  br i1 %180, label %181, label %194, !dbg !713

181:                                              ; preds = %127
  %182 = bitcast i32* %161 to i8*, !dbg !714
  %183 = call i8* inttoptr (i64 1 to i8* (i8*, i8*)*)(i8* bitcast (%struct.bpf_map_def* @tx_ports to i8*), i8* nonnull %182) #10, !dbg !717
  %184 = icmp eq i8* %183, null, !dbg !717
  br i1 %184, label %194, label %185, !dbg !718

185:                                              ; preds = %181
  %186 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %93, i64 0, i32 0, i64 0, !dbg !719
  %187 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 12, i64 0, !dbg !719
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(6) %186, i8* noundef nonnull align 2 dereferenceable(6) %187, i64 6, i1 false) #10, !dbg !719
  %188 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %93, i64 0, i32 1, i64 0, !dbg !720
  %189 = getelementptr inbounds %struct.bpf_fib_lookup, %struct.bpf_fib_lookup* %9, i64 0, i32 11, i64 0, !dbg !720
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(6) %188, i8* noundef nonnull align 4 dereferenceable(6) %189, i64 6, i1 false) #10, !dbg !720
  %190 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %93, i64 0, i32 2, !dbg !721
  store i16 8, i16* %190, align 1, !dbg !722, !tbaa !567
  %191 = load i32, i32* %161, align 4, !dbg !723, !tbaa !684
  %192 = call i64 inttoptr (i64 51 to i64 (i8*, i32, i64)*)(i8* bitcast (%struct.bpf_map_def* @tx_ports to i8*), i32 %191, i64 0) #10, !dbg !724
  %193 = trunc i64 %192 to i32, !dbg !724
  br label %194, !dbg !725

194:                                              ; preds = %185, %181, %127
  %195 = phi i32 [ %193, %185 ], [ 2, %181 ], [ 3, %127 ], !dbg !448
  call void @llvm.lifetime.end.p0i8(i64 64, i8* nonnull %158) #10, !dbg !726
  br label %196

196:                                              ; preds = %194, %119
  %197 = phi i32 [ %195, %194 ], [ -1, %119 ], !dbg !448
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %121) #10, !dbg !726
  br label %198

198:                                              ; preds = %196, %115
  %199 = phi i32 [ %197, %196 ], [ -1, %115 ], !dbg !448
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %116) #10, !dbg !726
  br label %200

200:                                              ; preds = %198, %108, %104, %100, %97, %86, %82, %79, %76, %72, %61, %57, %56
  %201 = phi i32 [ 1, %57 ], [ %199, %198 ], [ 1, %82 ], [ -1, %86 ], [ 1, %97 ], [ -1, %100 ], [ -1, %104 ], [ -1, %108 ], [ 1, %56 ], [ 1, %61 ], [ 1, %76 ], [ 1, %79 ], [ 1, %72 ], !dbg !448
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %49) #10, !dbg !726
  call void @llvm.lifetime.end.p0i8(i64 7, i8* nonnull %41) #10, !dbg !726
  br label %202

202:                                              ; preds = %1, %24, %27, %32, %200
  %203 = phi i32 [ 1, %1 ], [ %201, %200 ], [ 1, %24 ], [ 1, %27 ], [ 1, %32 ], !dbg !448
  ret i32 %203, !dbg !727
}

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #2

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define i32 @pass(%struct.xdp_md* nocapture readnone %0) #4 section "xdp_pass" !dbg !728 {
  call void @llvm.dbg.value(metadata %struct.xdp_md* undef, metadata !730, metadata !DIExpression()), !dbg !731
  ret i32 2, !dbg !732
}

; Function Attrs: inlinehint nofree nosync nounwind
define internal fastcc void @siphash(i8* readonly %0, i64 %1, i8* nocapture %2) unnamed_addr #5 !dbg !733 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !740, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %1, metadata !741, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i8* %2, metadata !742, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 8, metadata !743, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 7742937296321867630, metadata !744, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 7234298763096783205, metadata !745, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 1737014066054957595, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 2838956387997192, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 508087720900697359, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 1152921535143091222, metadata !749, metadata !DIExpression()), !dbg !756
  %4 = and i64 %1, -8, !dbg !757
  %5 = getelementptr inbounds i8, i8* %0, i64 %4, !dbg !757
  call void @llvm.dbg.value(metadata i8* %5, metadata !752, metadata !DIExpression()), !dbg !756
  %6 = trunc i64 %1 to i32, !dbg !758
  %7 = and i32 %6, 7, !dbg !758
  call void @llvm.dbg.value(metadata i32 %7, metadata !753, metadata !DIExpression()), !dbg !756
  %8 = shl i64 %1, 56, !dbg !759
  call void @llvm.dbg.value(metadata i64 %8, metadata !755, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 2838956387997192, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i8* %0, metadata !740, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 1737014066054957595, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 1152921535143091222, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 508087720900697359, metadata !748, metadata !DIExpression()), !dbg !756
  %9 = icmp eq i64 %4, 0, !dbg !760
  br i1 %9, label %85, label %10, !dbg !763

10:                                               ; preds = %3, %10
  %11 = phi i8* [ %83, %10 ], [ %0, %3 ]
  %12 = phi i64 [ %82, %10 ], [ 1737014066054957595, %3 ]
  %13 = phi i64 [ %80, %10 ], [ 2838956387997192, %3 ]
  %14 = phi i64 [ %77, %10 ], [ 1152921535143091222, %3 ]
  %15 = phi i64 [ %81, %10 ], [ 508087720900697359, %3 ]
  call void @llvm.dbg.value(metadata i8* %11, metadata !740, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %12, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %13, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %14, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %15, metadata !748, metadata !DIExpression()), !dbg !756
  %16 = load i8, i8* %11, align 1, !dbg !764, !tbaa !691
  %17 = zext i8 %16 to i64, !dbg !764
  %18 = getelementptr inbounds i8, i8* %11, i64 1, !dbg !764
  %19 = load i8, i8* %18, align 1, !dbg !764, !tbaa !691
  %20 = zext i8 %19 to i64, !dbg !764
  %21 = shl nuw nsw i64 %20, 8, !dbg !764
  %22 = or i64 %21, %17, !dbg !764
  %23 = getelementptr inbounds i8, i8* %11, i64 2, !dbg !764
  %24 = load i8, i8* %23, align 1, !dbg !764, !tbaa !691
  %25 = zext i8 %24 to i64, !dbg !764
  %26 = shl nuw nsw i64 %25, 16, !dbg !764
  %27 = or i64 %22, %26, !dbg !764
  %28 = getelementptr inbounds i8, i8* %11, i64 3, !dbg !764
  %29 = load i8, i8* %28, align 1, !dbg !764, !tbaa !691
  %30 = zext i8 %29 to i64, !dbg !764
  %31 = shl nuw nsw i64 %30, 24, !dbg !764
  %32 = or i64 %27, %31, !dbg !764
  %33 = getelementptr inbounds i8, i8* %11, i64 4, !dbg !764
  %34 = load i8, i8* %33, align 1, !dbg !764, !tbaa !691
  %35 = zext i8 %34 to i64, !dbg !764
  %36 = shl nuw nsw i64 %35, 32, !dbg !764
  %37 = or i64 %32, %36, !dbg !764
  %38 = getelementptr inbounds i8, i8* %11, i64 5, !dbg !764
  %39 = load i8, i8* %38, align 1, !dbg !764, !tbaa !691
  %40 = zext i8 %39 to i64, !dbg !764
  %41 = shl nuw nsw i64 %40, 40, !dbg !764
  %42 = or i64 %37, %41, !dbg !764
  %43 = getelementptr inbounds i8, i8* %11, i64 6, !dbg !764
  %44 = load i8, i8* %43, align 1, !dbg !764, !tbaa !691
  %45 = zext i8 %44 to i64, !dbg !764
  %46 = shl nuw nsw i64 %45, 48, !dbg !764
  %47 = or i64 %42, %46, !dbg !764
  %48 = getelementptr inbounds i8, i8* %11, i64 7, !dbg !764
  %49 = load i8, i8* %48, align 1, !dbg !764, !tbaa !691
  %50 = zext i8 %49 to i64, !dbg !764
  %51 = shl nuw i64 %50, 56, !dbg !764
  %52 = or i64 %47, %51, !dbg !764
  call void @llvm.dbg.value(metadata i64 %52, metadata !750, metadata !DIExpression()), !dbg !756
  %53 = xor i64 %52, %14, !dbg !766
  call void @llvm.dbg.value(metadata i64 %53, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %12, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %13, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %15, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %12, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %13, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %53, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %15, metadata !748, metadata !DIExpression()), !dbg !756
  %54 = add i64 %12, %13, !dbg !767
  call void @llvm.dbg.value(metadata i64 %54, metadata !746, metadata !DIExpression()), !dbg !756
  %55 = tail call i64 @llvm.fshl.i64(i64 %13, i64 %13, i64 13), !dbg !767
  call void @llvm.dbg.value(metadata i64 %55, metadata !747, metadata !DIExpression()), !dbg !756
  %56 = xor i64 %54, %55, !dbg !767
  call void @llvm.dbg.value(metadata i64 %56, metadata !747, metadata !DIExpression()), !dbg !756
  %57 = tail call i64 @llvm.fshl.i64(i64 %54, i64 %54, i64 32), !dbg !767
  call void @llvm.dbg.value(metadata i64 %57, metadata !746, metadata !DIExpression()), !dbg !756
  %58 = add i64 %53, %15, !dbg !767
  call void @llvm.dbg.value(metadata i64 %58, metadata !748, metadata !DIExpression()), !dbg !756
  %59 = tail call i64 @llvm.fshl.i64(i64 %53, i64 %53, i64 16), !dbg !767
  call void @llvm.dbg.value(metadata i64 %59, metadata !749, metadata !DIExpression()), !dbg !756
  %60 = xor i64 %59, %58, !dbg !767
  call void @llvm.dbg.value(metadata i64 %60, metadata !749, metadata !DIExpression()), !dbg !756
  %61 = add i64 %57, %60, !dbg !767
  call void @llvm.dbg.value(metadata i64 %61, metadata !746, metadata !DIExpression()), !dbg !756
  %62 = tail call i64 @llvm.fshl.i64(i64 %60, i64 %60, i64 21), !dbg !767
  call void @llvm.dbg.value(metadata i64 %62, metadata !749, metadata !DIExpression()), !dbg !756
  %63 = xor i64 %61, %62, !dbg !767
  call void @llvm.dbg.value(metadata i64 %63, metadata !749, metadata !DIExpression()), !dbg !756
  %64 = add i64 %56, %58, !dbg !767
  call void @llvm.dbg.value(metadata i64 %64, metadata !748, metadata !DIExpression()), !dbg !756
  %65 = tail call i64 @llvm.fshl.i64(i64 %56, i64 %56, i64 17), !dbg !767
  call void @llvm.dbg.value(metadata i64 %65, metadata !747, metadata !DIExpression()), !dbg !756
  %66 = xor i64 %65, %64, !dbg !767
  call void @llvm.dbg.value(metadata i64 %66, metadata !747, metadata !DIExpression()), !dbg !756
  %67 = tail call i64 @llvm.fshl.i64(i64 %64, i64 %64, i64 32), !dbg !767
  call void @llvm.dbg.value(metadata i64 %67, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %61, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %66, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %63, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %67, metadata !748, metadata !DIExpression()), !dbg !756
  %68 = add i64 %61, %66, !dbg !767
  call void @llvm.dbg.value(metadata i64 %68, metadata !746, metadata !DIExpression()), !dbg !756
  %69 = tail call i64 @llvm.fshl.i64(i64 %66, i64 %66, i64 13), !dbg !767
  call void @llvm.dbg.value(metadata i64 %69, metadata !747, metadata !DIExpression()), !dbg !756
  %70 = xor i64 %68, %69, !dbg !767
  call void @llvm.dbg.value(metadata i64 %70, metadata !747, metadata !DIExpression()), !dbg !756
  %71 = tail call i64 @llvm.fshl.i64(i64 %68, i64 %68, i64 32), !dbg !767
  call void @llvm.dbg.value(metadata i64 %71, metadata !746, metadata !DIExpression()), !dbg !756
  %72 = add i64 %63, %67, !dbg !767
  call void @llvm.dbg.value(metadata i64 %72, metadata !748, metadata !DIExpression()), !dbg !756
  %73 = tail call i64 @llvm.fshl.i64(i64 %63, i64 %63, i64 16), !dbg !767
  call void @llvm.dbg.value(metadata i64 %73, metadata !749, metadata !DIExpression()), !dbg !756
  %74 = xor i64 %73, %72, !dbg !767
  call void @llvm.dbg.value(metadata i64 %74, metadata !749, metadata !DIExpression()), !dbg !756
  %75 = add i64 %71, %74, !dbg !767
  call void @llvm.dbg.value(metadata i64 %75, metadata !746, metadata !DIExpression()), !dbg !756
  %76 = tail call i64 @llvm.fshl.i64(i64 %74, i64 %74, i64 21), !dbg !767
  call void @llvm.dbg.value(metadata i64 %76, metadata !749, metadata !DIExpression()), !dbg !756
  %77 = xor i64 %75, %76, !dbg !767
  call void @llvm.dbg.value(metadata i64 %77, metadata !749, metadata !DIExpression()), !dbg !756
  %78 = add i64 %70, %72, !dbg !767
  call void @llvm.dbg.value(metadata i64 %78, metadata !748, metadata !DIExpression()), !dbg !756
  %79 = tail call i64 @llvm.fshl.i64(i64 %70, i64 %70, i64 17), !dbg !767
  call void @llvm.dbg.value(metadata i64 %79, metadata !747, metadata !DIExpression()), !dbg !756
  %80 = xor i64 %79, %78, !dbg !767
  call void @llvm.dbg.value(metadata i64 %80, metadata !747, metadata !DIExpression()), !dbg !756
  %81 = tail call i64 @llvm.fshl.i64(i64 %78, i64 %78, i64 32), !dbg !767
  call void @llvm.dbg.value(metadata i64 %81, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 2, metadata !751, metadata !DIExpression()), !dbg !756
  %82 = xor i64 %75, %52, !dbg !771
  call void @llvm.dbg.value(metadata i64 %82, metadata !746, metadata !DIExpression()), !dbg !756
  %83 = getelementptr inbounds i8, i8* %11, i64 8, !dbg !772
  call void @llvm.dbg.value(metadata i8* %83, metadata !740, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %80, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %77, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %81, metadata !748, metadata !DIExpression()), !dbg !756
  %84 = icmp eq i8* %83, %5, !dbg !760
  br i1 %84, label %85, label %10, !dbg !763, !llvm.loop !773

85:                                               ; preds = %10, %3
  %86 = phi i64 [ 508087720900697359, %3 ], [ %81, %10 ], !dbg !776
  %87 = phi i64 [ 1152921535143091222, %3 ], [ %77, %10 ], !dbg !756
  %88 = phi i64 [ 2838956387997192, %3 ], [ %80, %10 ], !dbg !777
  %89 = phi i64 [ 1737014066054957595, %3 ], [ %82, %10 ], !dbg !756
  %90 = phi i8* [ %0, %3 ], [ %5, %10 ]
  switch i32 %7, label %137 [
    i32 7, label %91
    i32 6, label %97
    i32 5, label %104
    i32 4, label %111
    i32 3, label %118
    i32 2, label %125
    i32 1, label %132
  ], !dbg !779

91:                                               ; preds = %85
  %92 = getelementptr inbounds i8, i8* %90, i64 6, !dbg !780
  %93 = load i8, i8* %92, align 1, !dbg !780, !tbaa !691
  %94 = zext i8 %93 to i64, !dbg !782
  %95 = shl nuw nsw i64 %94, 48, !dbg !783
  %96 = or i64 %95, %8, !dbg !784
  call void @llvm.dbg.value(metadata i64 %96, metadata !755, metadata !DIExpression()), !dbg !756
  br label %97, !dbg !785

97:                                               ; preds = %85, %91
  %98 = phi i64 [ %8, %85 ], [ %96, %91 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %98, metadata !755, metadata !DIExpression()), !dbg !756
  %99 = getelementptr inbounds i8, i8* %90, i64 5, !dbg !786
  %100 = load i8, i8* %99, align 1, !dbg !786, !tbaa !691
  %101 = zext i8 %100 to i64, !dbg !787
  %102 = shl nuw nsw i64 %101, 40, !dbg !788
  %103 = or i64 %102, %98, !dbg !789
  call void @llvm.dbg.value(metadata i64 %103, metadata !755, metadata !DIExpression()), !dbg !756
  br label %104, !dbg !790

104:                                              ; preds = %85, %97
  %105 = phi i64 [ %8, %85 ], [ %103, %97 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %105, metadata !755, metadata !DIExpression()), !dbg !756
  %106 = getelementptr inbounds i8, i8* %90, i64 4, !dbg !791
  %107 = load i8, i8* %106, align 1, !dbg !791, !tbaa !691
  %108 = zext i8 %107 to i64, !dbg !792
  %109 = shl nuw nsw i64 %108, 32, !dbg !793
  %110 = or i64 %109, %105, !dbg !794
  call void @llvm.dbg.value(metadata i64 %110, metadata !755, metadata !DIExpression()), !dbg !756
  br label %111, !dbg !795

111:                                              ; preds = %85, %104
  %112 = phi i64 [ %8, %85 ], [ %110, %104 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %112, metadata !755, metadata !DIExpression()), !dbg !756
  %113 = getelementptr inbounds i8, i8* %90, i64 3, !dbg !796
  %114 = load i8, i8* %113, align 1, !dbg !796, !tbaa !691
  %115 = zext i8 %114 to i64, !dbg !797
  %116 = shl nuw nsw i64 %115, 24, !dbg !798
  %117 = or i64 %116, %112, !dbg !799
  call void @llvm.dbg.value(metadata i64 %117, metadata !755, metadata !DIExpression()), !dbg !756
  br label %118, !dbg !800

118:                                              ; preds = %85, %111
  %119 = phi i64 [ %8, %85 ], [ %117, %111 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %119, metadata !755, metadata !DIExpression()), !dbg !756
  %120 = getelementptr inbounds i8, i8* %90, i64 2, !dbg !801
  %121 = load i8, i8* %120, align 1, !dbg !801, !tbaa !691
  %122 = zext i8 %121 to i64, !dbg !802
  %123 = shl nuw nsw i64 %122, 16, !dbg !803
  %124 = or i64 %123, %119, !dbg !804
  call void @llvm.dbg.value(metadata i64 %124, metadata !755, metadata !DIExpression()), !dbg !756
  br label %125, !dbg !805

125:                                              ; preds = %85, %118
  %126 = phi i64 [ %8, %85 ], [ %124, %118 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %126, metadata !755, metadata !DIExpression()), !dbg !756
  %127 = getelementptr inbounds i8, i8* %90, i64 1, !dbg !806
  %128 = load i8, i8* %127, align 1, !dbg !806, !tbaa !691
  %129 = zext i8 %128 to i64, !dbg !807
  %130 = shl nuw nsw i64 %129, 8, !dbg !808
  %131 = or i64 %130, %126, !dbg !809
  call void @llvm.dbg.value(metadata i64 %131, metadata !755, metadata !DIExpression()), !dbg !756
  br label %132, !dbg !810

132:                                              ; preds = %85, %125
  %133 = phi i64 [ %8, %85 ], [ %131, %125 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %133, metadata !755, metadata !DIExpression()), !dbg !756
  %134 = load i8, i8* %90, align 1, !dbg !811, !tbaa !691
  %135 = zext i8 %134 to i64, !dbg !812
  %136 = or i64 %133, %135, !dbg !813
  call void @llvm.dbg.value(metadata i64 %136, metadata !755, metadata !DIExpression()), !dbg !756
  br label %137, !dbg !814

137:                                              ; preds = %85, %132
  %138 = phi i64 [ %8, %85 ], [ %136, %132 ], !dbg !756
  call void @llvm.dbg.value(metadata i64 %138, metadata !755, metadata !DIExpression()), !dbg !756
  %139 = xor i64 %138, %87, !dbg !815
  call void @llvm.dbg.value(metadata i64 %139, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %89, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %88, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %86, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %89, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %88, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %139, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %86, metadata !748, metadata !DIExpression()), !dbg !756
  %140 = add i64 %89, %88, !dbg !816
  call void @llvm.dbg.value(metadata i64 %140, metadata !746, metadata !DIExpression()), !dbg !756
  %141 = tail call i64 @llvm.fshl.i64(i64 %88, i64 %88, i64 13), !dbg !816
  call void @llvm.dbg.value(metadata i64 %141, metadata !747, metadata !DIExpression()), !dbg !756
  %142 = xor i64 %140, %141, !dbg !816
  call void @llvm.dbg.value(metadata i64 %142, metadata !747, metadata !DIExpression()), !dbg !756
  %143 = tail call i64 @llvm.fshl.i64(i64 %140, i64 %140, i64 32), !dbg !816
  call void @llvm.dbg.value(metadata i64 %143, metadata !746, metadata !DIExpression()), !dbg !756
  %144 = add i64 %139, %86, !dbg !816
  call void @llvm.dbg.value(metadata i64 %144, metadata !748, metadata !DIExpression()), !dbg !756
  %145 = tail call i64 @llvm.fshl.i64(i64 %139, i64 %139, i64 16), !dbg !816
  call void @llvm.dbg.value(metadata i64 %145, metadata !749, metadata !DIExpression()), !dbg !756
  %146 = xor i64 %145, %144, !dbg !816
  call void @llvm.dbg.value(metadata i64 %146, metadata !749, metadata !DIExpression()), !dbg !756
  %147 = add i64 %143, %146, !dbg !816
  call void @llvm.dbg.value(metadata i64 %147, metadata !746, metadata !DIExpression()), !dbg !756
  %148 = tail call i64 @llvm.fshl.i64(i64 %146, i64 %146, i64 21), !dbg !816
  call void @llvm.dbg.value(metadata i64 %148, metadata !749, metadata !DIExpression()), !dbg !756
  %149 = xor i64 %147, %148, !dbg !816
  call void @llvm.dbg.value(metadata i64 %149, metadata !749, metadata !DIExpression()), !dbg !756
  %150 = add i64 %142, %144, !dbg !816
  call void @llvm.dbg.value(metadata i64 %150, metadata !748, metadata !DIExpression()), !dbg !756
  %151 = tail call i64 @llvm.fshl.i64(i64 %142, i64 %142, i64 17), !dbg !816
  call void @llvm.dbg.value(metadata i64 %151, metadata !747, metadata !DIExpression()), !dbg !756
  %152 = xor i64 %151, %150, !dbg !816
  call void @llvm.dbg.value(metadata i64 %152, metadata !747, metadata !DIExpression()), !dbg !756
  %153 = tail call i64 @llvm.fshl.i64(i64 %150, i64 %150, i64 32), !dbg !816
  call void @llvm.dbg.value(metadata i64 %153, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %147, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %152, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %149, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %153, metadata !748, metadata !DIExpression()), !dbg !756
  %154 = add i64 %147, %152, !dbg !816
  call void @llvm.dbg.value(metadata i64 %154, metadata !746, metadata !DIExpression()), !dbg !756
  %155 = tail call i64 @llvm.fshl.i64(i64 %152, i64 %152, i64 13), !dbg !816
  call void @llvm.dbg.value(metadata i64 %155, metadata !747, metadata !DIExpression()), !dbg !756
  %156 = xor i64 %154, %155, !dbg !816
  call void @llvm.dbg.value(metadata i64 %156, metadata !747, metadata !DIExpression()), !dbg !756
  %157 = tail call i64 @llvm.fshl.i64(i64 %154, i64 %154, i64 32), !dbg !816
  call void @llvm.dbg.value(metadata i64 %157, metadata !746, metadata !DIExpression()), !dbg !756
  %158 = add i64 %149, %153, !dbg !816
  call void @llvm.dbg.value(metadata i64 %158, metadata !748, metadata !DIExpression()), !dbg !756
  %159 = tail call i64 @llvm.fshl.i64(i64 %149, i64 %149, i64 16), !dbg !816
  call void @llvm.dbg.value(metadata i64 %159, metadata !749, metadata !DIExpression()), !dbg !756
  %160 = xor i64 %159, %158, !dbg !816
  call void @llvm.dbg.value(metadata i64 %160, metadata !749, metadata !DIExpression()), !dbg !756
  %161 = add i64 %157, %160, !dbg !816
  call void @llvm.dbg.value(metadata i64 %161, metadata !746, metadata !DIExpression()), !dbg !756
  %162 = tail call i64 @llvm.fshl.i64(i64 %160, i64 %160, i64 21), !dbg !816
  call void @llvm.dbg.value(metadata i64 %162, metadata !749, metadata !DIExpression()), !dbg !756
  %163 = xor i64 %161, %162, !dbg !816
  call void @llvm.dbg.value(metadata i64 %163, metadata !749, metadata !DIExpression()), !dbg !756
  %164 = add i64 %156, %158, !dbg !816
  call void @llvm.dbg.value(metadata i64 %164, metadata !748, metadata !DIExpression()), !dbg !756
  %165 = tail call i64 @llvm.fshl.i64(i64 %156, i64 %156, i64 17), !dbg !816
  call void @llvm.dbg.value(metadata i64 %165, metadata !747, metadata !DIExpression()), !dbg !756
  %166 = xor i64 %165, %164, !dbg !816
  call void @llvm.dbg.value(metadata i64 %166, metadata !747, metadata !DIExpression()), !dbg !756
  %167 = tail call i64 @llvm.fshl.i64(i64 %164, i64 %164, i64 32), !dbg !816
  call void @llvm.dbg.value(metadata i64 %167, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 2, metadata !751, metadata !DIExpression()), !dbg !756
  %168 = xor i64 %161, %138, !dbg !820
  call void @llvm.dbg.value(metadata i64 %168, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %167, metadata !748, metadata !DIExpression(DW_OP_constu, 255, DW_OP_xor, DW_OP_stack_value)), !dbg !756
  %169 = xor i64 %167, 255, !dbg !821
  call void @llvm.dbg.value(metadata i64 %169, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %167, metadata !748, metadata !DIExpression(DW_OP_constu, 255, DW_OP_xor, DW_OP_stack_value)), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %168, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %166, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %163, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %168, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 0, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %166, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %163, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %169, metadata !748, metadata !DIExpression()), !dbg !756
  %170 = add i64 %168, %166, !dbg !823
  call void @llvm.dbg.value(metadata i64 %170, metadata !746, metadata !DIExpression()), !dbg !756
  %171 = tail call i64 @llvm.fshl.i64(i64 %166, i64 %166, i64 13), !dbg !823
  call void @llvm.dbg.value(metadata i64 %171, metadata !747, metadata !DIExpression()), !dbg !756
  %172 = xor i64 %170, %171, !dbg !823
  call void @llvm.dbg.value(metadata i64 %172, metadata !747, metadata !DIExpression()), !dbg !756
  %173 = tail call i64 @llvm.fshl.i64(i64 %170, i64 %170, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %173, metadata !746, metadata !DIExpression()), !dbg !756
  %174 = add i64 %163, %169, !dbg !823
  call void @llvm.dbg.value(metadata i64 %174, metadata !748, metadata !DIExpression()), !dbg !756
  %175 = tail call i64 @llvm.fshl.i64(i64 %163, i64 %163, i64 16), !dbg !823
  call void @llvm.dbg.value(metadata i64 %175, metadata !749, metadata !DIExpression()), !dbg !756
  %176 = xor i64 %175, %174, !dbg !823
  call void @llvm.dbg.value(metadata i64 %176, metadata !749, metadata !DIExpression()), !dbg !756
  %177 = add i64 %173, %176, !dbg !823
  call void @llvm.dbg.value(metadata i64 %177, metadata !746, metadata !DIExpression()), !dbg !756
  %178 = tail call i64 @llvm.fshl.i64(i64 %176, i64 %176, i64 21), !dbg !823
  call void @llvm.dbg.value(metadata i64 %178, metadata !749, metadata !DIExpression()), !dbg !756
  %179 = xor i64 %177, %178, !dbg !823
  call void @llvm.dbg.value(metadata i64 %179, metadata !749, metadata !DIExpression()), !dbg !756
  %180 = add i64 %172, %174, !dbg !823
  call void @llvm.dbg.value(metadata i64 %180, metadata !748, metadata !DIExpression()), !dbg !756
  %181 = tail call i64 @llvm.fshl.i64(i64 %172, i64 %172, i64 17), !dbg !823
  call void @llvm.dbg.value(metadata i64 %181, metadata !747, metadata !DIExpression()), !dbg !756
  %182 = xor i64 %181, %180, !dbg !823
  call void @llvm.dbg.value(metadata i64 %182, metadata !747, metadata !DIExpression()), !dbg !756
  %183 = tail call i64 @llvm.fshl.i64(i64 %180, i64 %180, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %183, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %177, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 1, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %182, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %179, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %183, metadata !748, metadata !DIExpression()), !dbg !756
  %184 = add i64 %177, %182, !dbg !823
  call void @llvm.dbg.value(metadata i64 %184, metadata !746, metadata !DIExpression()), !dbg !756
  %185 = tail call i64 @llvm.fshl.i64(i64 %182, i64 %182, i64 13), !dbg !823
  call void @llvm.dbg.value(metadata i64 %185, metadata !747, metadata !DIExpression()), !dbg !756
  %186 = xor i64 %184, %185, !dbg !823
  call void @llvm.dbg.value(metadata i64 %186, metadata !747, metadata !DIExpression()), !dbg !756
  %187 = tail call i64 @llvm.fshl.i64(i64 %184, i64 %184, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %187, metadata !746, metadata !DIExpression()), !dbg !756
  %188 = add i64 %179, %183, !dbg !823
  call void @llvm.dbg.value(metadata i64 %188, metadata !748, metadata !DIExpression()), !dbg !756
  %189 = tail call i64 @llvm.fshl.i64(i64 %179, i64 %179, i64 16), !dbg !823
  call void @llvm.dbg.value(metadata i64 %189, metadata !749, metadata !DIExpression()), !dbg !756
  %190 = xor i64 %189, %188, !dbg !823
  call void @llvm.dbg.value(metadata i64 %190, metadata !749, metadata !DIExpression()), !dbg !756
  %191 = add i64 %187, %190, !dbg !823
  call void @llvm.dbg.value(metadata i64 %191, metadata !746, metadata !DIExpression()), !dbg !756
  %192 = tail call i64 @llvm.fshl.i64(i64 %190, i64 %190, i64 21), !dbg !823
  call void @llvm.dbg.value(metadata i64 %192, metadata !749, metadata !DIExpression()), !dbg !756
  %193 = xor i64 %191, %192, !dbg !823
  call void @llvm.dbg.value(metadata i64 %193, metadata !749, metadata !DIExpression()), !dbg !756
  %194 = add i64 %186, %188, !dbg !823
  call void @llvm.dbg.value(metadata i64 %194, metadata !748, metadata !DIExpression()), !dbg !756
  %195 = tail call i64 @llvm.fshl.i64(i64 %186, i64 %186, i64 17), !dbg !823
  call void @llvm.dbg.value(metadata i64 %195, metadata !747, metadata !DIExpression()), !dbg !756
  %196 = xor i64 %195, %194, !dbg !823
  call void @llvm.dbg.value(metadata i64 %196, metadata !747, metadata !DIExpression()), !dbg !756
  %197 = tail call i64 @llvm.fshl.i64(i64 %194, i64 %194, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %197, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 2, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %191, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 2, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %196, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %193, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %197, metadata !748, metadata !DIExpression()), !dbg !756
  %198 = add i64 %191, %196, !dbg !823
  call void @llvm.dbg.value(metadata i64 %198, metadata !746, metadata !DIExpression()), !dbg !756
  %199 = tail call i64 @llvm.fshl.i64(i64 %196, i64 %196, i64 13), !dbg !823
  call void @llvm.dbg.value(metadata i64 %199, metadata !747, metadata !DIExpression()), !dbg !756
  %200 = xor i64 %198, %199, !dbg !823
  call void @llvm.dbg.value(metadata i64 %200, metadata !747, metadata !DIExpression()), !dbg !756
  %201 = tail call i64 @llvm.fshl.i64(i64 %198, i64 %198, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %201, metadata !746, metadata !DIExpression()), !dbg !756
  %202 = add i64 %193, %197, !dbg !823
  call void @llvm.dbg.value(metadata i64 %202, metadata !748, metadata !DIExpression()), !dbg !756
  %203 = tail call i64 @llvm.fshl.i64(i64 %193, i64 %193, i64 16), !dbg !823
  call void @llvm.dbg.value(metadata i64 %203, metadata !749, metadata !DIExpression()), !dbg !756
  %204 = xor i64 %203, %202, !dbg !823
  call void @llvm.dbg.value(metadata i64 %204, metadata !749, metadata !DIExpression()), !dbg !756
  %205 = add i64 %201, %204, !dbg !823
  call void @llvm.dbg.value(metadata i64 %205, metadata !746, metadata !DIExpression()), !dbg !756
  %206 = tail call i64 @llvm.fshl.i64(i64 %204, i64 %204, i64 21), !dbg !823
  call void @llvm.dbg.value(metadata i64 %206, metadata !749, metadata !DIExpression()), !dbg !756
  %207 = xor i64 %205, %206, !dbg !823
  call void @llvm.dbg.value(metadata i64 %207, metadata !749, metadata !DIExpression()), !dbg !756
  %208 = add i64 %200, %202, !dbg !823
  call void @llvm.dbg.value(metadata i64 %208, metadata !748, metadata !DIExpression()), !dbg !756
  %209 = tail call i64 @llvm.fshl.i64(i64 %200, i64 %200, i64 17), !dbg !823
  call void @llvm.dbg.value(metadata i64 %209, metadata !747, metadata !DIExpression()), !dbg !756
  %210 = xor i64 %209, %208, !dbg !823
  call void @llvm.dbg.value(metadata i64 %210, metadata !747, metadata !DIExpression()), !dbg !756
  %211 = tail call i64 @llvm.fshl.i64(i64 %208, i64 %208, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %211, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 3, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %205, metadata !746, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 3, metadata !751, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %210, metadata !747, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %207, metadata !749, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i64 %211, metadata !748, metadata !DIExpression()), !dbg !756
  %212 = add i64 %205, %210, !dbg !823
  call void @llvm.dbg.value(metadata i64 %212, metadata !746, metadata !DIExpression()), !dbg !756
  %213 = tail call i64 @llvm.fshl.i64(i64 %210, i64 %210, i64 13), !dbg !823
  call void @llvm.dbg.value(metadata i64 %213, metadata !747, metadata !DIExpression()), !dbg !756
  %214 = xor i64 %212, %213, !dbg !823
  call void @llvm.dbg.value(metadata i64 %214, metadata !747, metadata !DIExpression()), !dbg !756
  %215 = tail call i64 @llvm.fshl.i64(i64 %212, i64 %212, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %215, metadata !746, metadata !DIExpression()), !dbg !756
  %216 = add i64 %207, %211, !dbg !823
  call void @llvm.dbg.value(metadata i64 %216, metadata !748, metadata !DIExpression()), !dbg !756
  %217 = tail call i64 @llvm.fshl.i64(i64 %207, i64 %207, i64 16), !dbg !823
  call void @llvm.dbg.value(metadata i64 %217, metadata !749, metadata !DIExpression()), !dbg !756
  %218 = xor i64 %217, %216, !dbg !823
  call void @llvm.dbg.value(metadata i64 %218, metadata !749, metadata !DIExpression()), !dbg !756
  %219 = add i64 %215, %218, !dbg !823
  call void @llvm.dbg.value(metadata i64 %219, metadata !746, metadata !DIExpression()), !dbg !756
  %220 = tail call i64 @llvm.fshl.i64(i64 %218, i64 %218, i64 21), !dbg !823
  call void @llvm.dbg.value(metadata i64 %220, metadata !749, metadata !DIExpression()), !dbg !756
  %221 = xor i64 %219, %220, !dbg !823
  call void @llvm.dbg.value(metadata i64 %221, metadata !749, metadata !DIExpression()), !dbg !756
  %222 = add i64 %214, %216, !dbg !823
  call void @llvm.dbg.value(metadata i64 %222, metadata !748, metadata !DIExpression()), !dbg !756
  %223 = tail call i64 @llvm.fshl.i64(i64 %214, i64 %214, i64 17), !dbg !823
  call void @llvm.dbg.value(metadata i64 %223, metadata !747, metadata !DIExpression()), !dbg !756
  %224 = xor i64 %223, %222, !dbg !823
  call void @llvm.dbg.value(metadata i64 %224, metadata !747, metadata !DIExpression()), !dbg !756
  %225 = tail call i64 @llvm.fshl.i64(i64 %222, i64 %222, i64 32), !dbg !823
  call void @llvm.dbg.value(metadata i64 %225, metadata !748, metadata !DIExpression()), !dbg !756
  call void @llvm.dbg.value(metadata i32 4, metadata !751, metadata !DIExpression()), !dbg !756
  %226 = xor i64 %221, %225, !dbg !827
  %227 = xor i64 %226, %224, !dbg !828
  %228 = xor i64 %227, %219, !dbg !829
  call void @llvm.dbg.value(metadata i64 %228, metadata !755, metadata !DIExpression()), !dbg !756
  %229 = trunc i64 %228 to i8, !dbg !830
  store i8 %229, i8* %2, align 1, !dbg !830, !tbaa !691
  %230 = lshr i64 %228, 8, !dbg !830
  %231 = trunc i64 %230 to i8, !dbg !830
  %232 = getelementptr inbounds i8, i8* %2, i64 1, !dbg !830
  store i8 %231, i8* %232, align 1, !dbg !830, !tbaa !691
  %233 = lshr i64 %228, 16, !dbg !830
  %234 = trunc i64 %233 to i8, !dbg !830
  %235 = getelementptr inbounds i8, i8* %2, i64 2, !dbg !830
  store i8 %234, i8* %235, align 1, !dbg !830, !tbaa !691
  %236 = lshr i64 %228, 24, !dbg !830
  %237 = trunc i64 %236 to i8, !dbg !830
  %238 = getelementptr inbounds i8, i8* %2, i64 3, !dbg !830
  store i8 %237, i8* %238, align 1, !dbg !830, !tbaa !691
  %239 = lshr i64 %228, 32, !dbg !830
  %240 = trunc i64 %239 to i8, !dbg !830
  %241 = getelementptr inbounds i8, i8* %2, i64 4, !dbg !830
  store i8 %240, i8* %241, align 1, !dbg !830, !tbaa !691
  %242 = lshr i64 %228, 40, !dbg !830
  %243 = trunc i64 %242 to i8, !dbg !830
  %244 = getelementptr inbounds i8, i8* %2, i64 5, !dbg !830
  store i8 %243, i8* %244, align 1, !dbg !830, !tbaa !691
  %245 = lshr i64 %228, 48, !dbg !830
  %246 = trunc i64 %245 to i8, !dbg !830
  %247 = getelementptr inbounds i8, i8* %2, i64 6, !dbg !830
  store i8 %246, i8* %247, align 1, !dbg !830, !tbaa !691
  %248 = lshr i64 %228, 56, !dbg !830
  %249 = trunc i64 %248 to i8, !dbg !830
  %250 = getelementptr inbounds i8, i8* %2, i64 7, !dbg !830
  store i8 %249, i8* %250, align 1, !dbg !830, !tbaa !691
  ret void, !dbg !831
}

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #6

; Function Attrs: mustprogress nofree norecurse nosync nounwind readonly willreturn
define internal fastcc zeroext i16 @compute_ipv4_checksum(i8* nocapture readonly %0) unnamed_addr #7 !dbg !832 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !836, metadata !DIExpression()), !dbg !839
  %2 = bitcast i8* %0 to <8 x i16>*, !dbg !840
  call void @llvm.dbg.value(metadata <8 x i16>* %2, metadata !837, metadata !DIExpression()), !dbg !839
  %3 = load <8 x i16>, <8 x i16>* %2, align 2, !dbg !840, !tbaa !841
  %4 = zext <8 x i16> %3 to <8 x i64>, !dbg !840
  %5 = getelementptr inbounds i8, i8* %0, i64 16, !dbg !842
  %6 = bitcast i8* %5 to i16*, !dbg !842
  %7 = load i16, i16* %6, align 2, !dbg !842, !tbaa !841
  %8 = zext i16 %7 to i64, !dbg !842
  %9 = getelementptr inbounds i8, i8* %0, i64 18, !dbg !843
  %10 = bitcast i8* %9 to i16*, !dbg !843
  %11 = load i16, i16* %10, align 2, !dbg !843, !tbaa !841
  %12 = zext i16 %11 to i64, !dbg !843
  %13 = call i64 @llvm.vector.reduce.add.v8i64(<8 x i64> %4), !dbg !844
  %14 = add nuw nsw i64 %13, %8, !dbg !842
  %15 = add nuw nsw i64 %14, %12, !dbg !843
  call void @llvm.dbg.value(metadata i64 %15, metadata !838, metadata !DIExpression(DW_OP_constu, 32, DW_OP_shl, DW_OP_constu, 32, DW_OP_shra, DW_OP_stack_value)), !dbg !839
  %16 = lshr i64 %15, 16, !dbg !845
  %17 = add nuw nsw i64 %16, %15, !dbg !846
  call void @llvm.dbg.value(metadata !DIArgList(i64 %15, i64 %15), metadata !838, metadata !DIExpression(DW_OP_LLVM_arg, 0, DW_OP_LLVM_arg, 1, DW_OP_constu, 4294901760, DW_OP_and, DW_OP_constu, 16, DW_OP_shr, DW_OP_plus, DW_OP_stack_value)), !dbg !839
  %18 = trunc i64 %17 to i16, !dbg !847
  %19 = xor i16 %18, -1, !dbg !847
  ret i16 %19, !dbg !848
}

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare i16 @llvm.bswap.i16(i16) #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #8

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i32 @llvm.bswap.i32(i32) #8

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.fshl.i64(i64, i64, i64) #8

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare i64 @llvm.bswap.i64(i64) #8

; Function Attrs: nofree nosync nounwind readnone willreturn
declare i64 @llvm.vector.reduce.add.v8i64(<8 x i64>) #9

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #3 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #4 = { mustprogress nofree norecurse nosync nounwind readnone willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #5 = { inlinehint nofree nosync nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #6 = { argmemonly mustprogress nofree nounwind willreturn writeonly }
attributes #7 = { mustprogress nofree norecurse nosync nounwind readonly willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #8 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #9 = { nofree nosync nounwind readnone willreturn }
attributes #10 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!331, !332, !333, !334, !335}
!llvm.ident = !{!336}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "tx_ports", scope: !2, file: !168, line: 17, type: !169, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0 (Red Hat 13.0.0-2.el9)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !56, globals: !165, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "xdp_balancer.c", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!4 = !{!5, !14, !45}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "xdp_action", file: !6, line: 5326, baseType: !7, size: 32, elements: !8)
!6 = !DIFile(filename: "/usr/include/linux/bpf.h", directory: "")
!7 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!8 = !{!9, !10, !11, !12, !13}
!9 = !DIEnumerator(name: "XDP_ABORTED", value: 0)
!10 = !DIEnumerator(name: "XDP_DROP", value: 1)
!11 = !DIEnumerator(name: "XDP_PASS", value: 2)
!12 = !DIEnumerator(name: "XDP_TX", value: 3)
!13 = !DIEnumerator(name: "XDP_REDIRECT", value: 4)
!14 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !15, line: 40, baseType: !7, size: 32, elements: !16)
!15 = !DIFile(filename: "/usr/include/netinet/in.h", directory: "")
!16 = !{!17, !18, !19, !20, !21, !22, !23, !24, !25, !26, !27, !28, !29, !30, !31, !32, !33, !34, !35, !36, !37, !38, !39, !40, !41, !42, !43, !44}
!17 = !DIEnumerator(name: "IPPROTO_IP", value: 0)
!18 = !DIEnumerator(name: "IPPROTO_ICMP", value: 1)
!19 = !DIEnumerator(name: "IPPROTO_IGMP", value: 2)
!20 = !DIEnumerator(name: "IPPROTO_IPIP", value: 4)
!21 = !DIEnumerator(name: "IPPROTO_TCP", value: 6)
!22 = !DIEnumerator(name: "IPPROTO_EGP", value: 8)
!23 = !DIEnumerator(name: "IPPROTO_PUP", value: 12)
!24 = !DIEnumerator(name: "IPPROTO_UDP", value: 17)
!25 = !DIEnumerator(name: "IPPROTO_IDP", value: 22)
!26 = !DIEnumerator(name: "IPPROTO_TP", value: 29)
!27 = !DIEnumerator(name: "IPPROTO_DCCP", value: 33)
!28 = !DIEnumerator(name: "IPPROTO_IPV6", value: 41)
!29 = !DIEnumerator(name: "IPPROTO_RSVP", value: 46)
!30 = !DIEnumerator(name: "IPPROTO_GRE", value: 47)
!31 = !DIEnumerator(name: "IPPROTO_ESP", value: 50)
!32 = !DIEnumerator(name: "IPPROTO_AH", value: 51)
!33 = !DIEnumerator(name: "IPPROTO_MTP", value: 92)
!34 = !DIEnumerator(name: "IPPROTO_BEETPH", value: 94)
!35 = !DIEnumerator(name: "IPPROTO_ENCAP", value: 98)
!36 = !DIEnumerator(name: "IPPROTO_PIM", value: 103)
!37 = !DIEnumerator(name: "IPPROTO_COMP", value: 108)
!38 = !DIEnumerator(name: "IPPROTO_SCTP", value: 132)
!39 = !DIEnumerator(name: "IPPROTO_UDPLITE", value: 136)
!40 = !DIEnumerator(name: "IPPROTO_MPLS", value: 137)
!41 = !DIEnumerator(name: "IPPROTO_ETHERNET", value: 143)
!42 = !DIEnumerator(name: "IPPROTO_RAW", value: 255)
!43 = !DIEnumerator(name: "IPPROTO_MPTCP", value: 262)
!44 = !DIEnumerator(name: "IPPROTO_MAX", value: 263)
!45 = !DICompositeType(tag: DW_TAG_enumeration_type, file: !6, line: 5935, baseType: !7, size: 32, elements: !46)
!46 = !{!47, !48, !49, !50, !51, !52, !53, !54, !55}
!47 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_SUCCESS", value: 0)
!48 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_BLACKHOLE", value: 1)
!49 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_UNREACHABLE", value: 2)
!50 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_PROHIBIT", value: 3)
!51 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_NOT_FWDED", value: 4)
!52 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_FWD_DISABLED", value: 5)
!53 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_UNSUPP_LWT", value: 6)
!54 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_NO_NEIGH", value: 7)
!55 = !DIEnumerator(name: "BPF_FIB_LKUP_RET_FRAG_NEEDED", value: 8)
!56 = !{!57, !58, !59, !60, !76, !81, !100, !108, !73, !124, !157, !77, !160, !162, !163}
!57 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!58 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!59 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!60 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !61, size: 64)
!61 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ethhdr", file: !62, line: 165, size: 112, elements: !63)
!62 = !DIFile(filename: "/usr/include/linux/if_ether.h", directory: "")
!63 = !{!64, !69, !70}
!64 = !DIDerivedType(tag: DW_TAG_member, name: "h_dest", scope: !61, file: !62, line: 166, baseType: !65, size: 48)
!65 = !DICompositeType(tag: DW_TAG_array_type, baseType: !66, size: 48, elements: !67)
!66 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!67 = !{!68}
!68 = !DISubrange(count: 6)
!69 = !DIDerivedType(tag: DW_TAG_member, name: "h_source", scope: !61, file: !62, line: 167, baseType: !65, size: 48, offset: 48)
!70 = !DIDerivedType(tag: DW_TAG_member, name: "h_proto", scope: !61, file: !62, line: 168, baseType: !71, size: 16, offset: 96)
!71 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be16", file: !72, line: 25, baseType: !73)
!72 = !DIFile(filename: "/usr/include/linux/types.h", directory: "")
!73 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u16", file: !74, line: 24, baseType: !75)
!74 = !DIFile(filename: "/usr/include/asm-generic/int-ll64.h", directory: "")
!75 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!76 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !77, size: 64)
!77 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !78, line: 24, baseType: !79)
!78 = !DIFile(filename: "/usr/include/bits/stdint-uintn.h", directory: "")
!79 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !80, line: 38, baseType: !66)
!80 = !DIFile(filename: "/usr/include/bits/types.h", directory: "")
!81 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !82, size: 64)
!82 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "iphdr", file: !83, line: 86, size: 160, elements: !84)
!83 = !DIFile(filename: "/usr/include/linux/ip.h", directory: "")
!84 = !{!85, !87, !88, !89, !90, !91, !92, !93, !94, !96, !99}
!85 = !DIDerivedType(tag: DW_TAG_member, name: "ihl", scope: !82, file: !83, line: 88, baseType: !86, size: 4, flags: DIFlagBitField, extraData: i64 0)
!86 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u8", file: !74, line: 21, baseType: !66)
!87 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !82, file: !83, line: 89, baseType: !86, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!88 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !82, file: !83, line: 96, baseType: !86, size: 8, offset: 8)
!89 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !82, file: !83, line: 97, baseType: !71, size: 16, offset: 16)
!90 = !DIDerivedType(tag: DW_TAG_member, name: "id", scope: !82, file: !83, line: 98, baseType: !71, size: 16, offset: 32)
!91 = !DIDerivedType(tag: DW_TAG_member, name: "frag_off", scope: !82, file: !83, line: 99, baseType: !71, size: 16, offset: 48)
!92 = !DIDerivedType(tag: DW_TAG_member, name: "ttl", scope: !82, file: !83, line: 100, baseType: !86, size: 8, offset: 64)
!93 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !82, file: !83, line: 101, baseType: !86, size: 8, offset: 72)
!94 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !82, file: !83, line: 102, baseType: !95, size: 16, offset: 80)
!95 = !DIDerivedType(tag: DW_TAG_typedef, name: "__sum16", file: !72, line: 31, baseType: !73)
!96 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !82, file: !83, line: 103, baseType: !97, size: 32, offset: 96)
!97 = !DIDerivedType(tag: DW_TAG_typedef, name: "__be32", file: !72, line: 27, baseType: !98)
!98 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u32", file: !74, line: 27, baseType: !7)
!99 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !82, file: !83, line: 104, baseType: !97, size: 32, offset: 128)
!100 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !101, size: 64)
!101 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "udphdr", file: !102, line: 23, size: 64, elements: !103)
!102 = !DIFile(filename: "/usr/include/linux/udp.h", directory: "")
!103 = !{!104, !105, !106, !107}
!104 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !101, file: !102, line: 24, baseType: !71, size: 16)
!105 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !101, file: !102, line: 25, baseType: !71, size: 16, offset: 16)
!106 = !DIDerivedType(tag: DW_TAG_member, name: "len", scope: !101, file: !102, line: 26, baseType: !71, size: 16, offset: 32)
!107 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !101, file: !102, line: 27, baseType: !95, size: 16, offset: 48)
!108 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !109, size: 64)
!109 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "lb_gue_hdr", file: !110, line: 51, size: 128, elements: !111)
!110 = !DIFile(filename: "./../common/gue.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!111 = !{!112, !113, !114, !115, !116, !117, !118, !119, !120}
!112 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !109, file: !110, line: 53, baseType: !86, size: 2, flags: DIFlagBitField, extraData: i64 0)
!113 = !DIDerivedType(tag: DW_TAG_member, name: "control", scope: !109, file: !110, line: 54, baseType: !86, size: 1, offset: 2, flags: DIFlagBitField, extraData: i64 0)
!114 = !DIDerivedType(tag: DW_TAG_member, name: "hlen", scope: !109, file: !110, line: 55, baseType: !86, size: 5, offset: 3, flags: DIFlagBitField, extraData: i64 0)
!115 = !DIDerivedType(tag: DW_TAG_member, name: "proto_ctype", scope: !109, file: !110, line: 56, baseType: !86, size: 8, offset: 8)
!116 = !DIDerivedType(tag: DW_TAG_member, name: "flags", scope: !109, file: !110, line: 57, baseType: !71, size: 16, offset: 16)
!117 = !DIDerivedType(tag: DW_TAG_member, name: "reversed", scope: !109, file: !110, line: 60, baseType: !73, size: 16, offset: 32)
!118 = !DIDerivedType(tag: DW_TAG_member, name: "next_hop", scope: !109, file: !110, line: 61, baseType: !86, size: 8, offset: 48)
!119 = !DIDerivedType(tag: DW_TAG_member, name: "hop_count", scope: !109, file: !110, line: 62, baseType: !86, size: 8, offset: 56)
!120 = !DIDerivedType(tag: DW_TAG_member, name: "hops", scope: !109, file: !110, line: 63, baseType: !121, size: 64, offset: 64)
!121 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 64, elements: !122)
!122 = !{!123}
!123 = !DISubrange(count: 2)
!124 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !125, size: 64)
!125 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "ipv6hdr", file: !126, line: 117, size: 320, elements: !127)
!126 = !DIFile(filename: "/usr/include/linux/ipv6.h", directory: "")
!127 = !{!128, !129, !130, !134, !135, !136, !137, !156}
!128 = !DIDerivedType(tag: DW_TAG_member, name: "priority", scope: !125, file: !126, line: 119, baseType: !86, size: 4, flags: DIFlagBitField, extraData: i64 0)
!129 = !DIDerivedType(tag: DW_TAG_member, name: "version", scope: !125, file: !126, line: 120, baseType: !86, size: 4, offset: 4, flags: DIFlagBitField, extraData: i64 0)
!130 = !DIDerivedType(tag: DW_TAG_member, name: "flow_lbl", scope: !125, file: !126, line: 127, baseType: !131, size: 24, offset: 8)
!131 = !DICompositeType(tag: DW_TAG_array_type, baseType: !86, size: 24, elements: !132)
!132 = !{!133}
!133 = !DISubrange(count: 3)
!134 = !DIDerivedType(tag: DW_TAG_member, name: "payload_len", scope: !125, file: !126, line: 129, baseType: !71, size: 16, offset: 32)
!135 = !DIDerivedType(tag: DW_TAG_member, name: "nexthdr", scope: !125, file: !126, line: 130, baseType: !86, size: 8, offset: 48)
!136 = !DIDerivedType(tag: DW_TAG_member, name: "hop_limit", scope: !125, file: !126, line: 131, baseType: !86, size: 8, offset: 56)
!137 = !DIDerivedType(tag: DW_TAG_member, name: "saddr", scope: !125, file: !126, line: 133, baseType: !138, size: 128, offset: 64)
!138 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "in6_addr", file: !139, line: 33, size: 128, elements: !140)
!139 = !DIFile(filename: "/usr/include/linux/in6.h", directory: "")
!140 = !{!141}
!141 = !DIDerivedType(tag: DW_TAG_member, name: "in6_u", scope: !138, file: !139, line: 40, baseType: !142, size: 128)
!142 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !138, file: !139, line: 34, size: 128, elements: !143)
!143 = !{!144, !148, !152}
!144 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr8", scope: !142, file: !139, line: 35, baseType: !145, size: 128)
!145 = !DICompositeType(tag: DW_TAG_array_type, baseType: !86, size: 128, elements: !146)
!146 = !{!147}
!147 = !DISubrange(count: 16)
!148 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr16", scope: !142, file: !139, line: 37, baseType: !149, size: 128)
!149 = !DICompositeType(tag: DW_TAG_array_type, baseType: !71, size: 128, elements: !150)
!150 = !{!151}
!151 = !DISubrange(count: 8)
!152 = !DIDerivedType(tag: DW_TAG_member, name: "u6_addr32", scope: !142, file: !139, line: 38, baseType: !153, size: 128)
!153 = !DICompositeType(tag: DW_TAG_array_type, baseType: !97, size: 128, elements: !154)
!154 = !{!155}
!155 = !DISubrange(count: 4)
!156 = !DIDerivedType(tag: DW_TAG_member, name: "daddr", scope: !125, file: !126, line: 134, baseType: !138, size: 128, offset: 192)
!157 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint64_t", file: !78, line: 27, baseType: !158)
!158 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint64_t", file: !80, line: 48, baseType: !159)
!159 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!160 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !78, line: 26, baseType: !161)
!161 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint32_t", file: !80, line: 42, baseType: !7)
!162 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !80, line: 40, baseType: !75)
!163 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !164, size: 64)
!164 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !78, line: 25, baseType: !162)
!165 = !{!0, !166, !177, !179, !181, !183, !186, !188, !192, !254, !256, !264, !278, !318, !325}
!166 = !DIGlobalVariableExpression(var: !167, expr: !DIExpression())
!167 = distinct !DIGlobalVariable(name: "config", scope: !2, file: !168, line: 29, type: !169, isLocal: false, isDefinition: true)
!168 = !DIFile(filename: "./maps.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!169 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_map_def", file: !170, line: 138, size: 160, elements: !171)
!170 = !DIFile(filename: "/usr/include/bpf/bpf_helpers.h", directory: "")
!171 = !{!172, !173, !174, !175, !176}
!172 = !DIDerivedType(tag: DW_TAG_member, name: "type", scope: !169, file: !170, line: 139, baseType: !7, size: 32)
!173 = !DIDerivedType(tag: DW_TAG_member, name: "key_size", scope: !169, file: !170, line: 140, baseType: !7, size: 32, offset: 32)
!174 = !DIDerivedType(tag: DW_TAG_member, name: "value_size", scope: !169, file: !170, line: 141, baseType: !7, size: 32, offset: 64)
!175 = !DIDerivedType(tag: DW_TAG_member, name: "max_entries", scope: !169, file: !170, line: 142, baseType: !7, size: 32, offset: 96)
!176 = !DIDerivedType(tag: DW_TAG_member, name: "map_flags", scope: !169, file: !170, line: 143, baseType: !7, size: 32, offset: 128)
!177 = !DIGlobalVariableExpression(var: !178, expr: !DIExpression())
!178 = distinct !DIGlobalVariable(name: "binds", scope: !2, file: !168, line: 41, type: !169, isLocal: false, isDefinition: true)
!179 = !DIGlobalVariableExpression(var: !180, expr: !DIExpression())
!180 = distinct !DIGlobalVariable(name: "bind_backends", scope: !2, file: !168, line: 59, type: !169, isLocal: false, isDefinition: true)
!181 = !DIGlobalVariableExpression(var: !182, expr: !DIExpression())
!182 = distinct !DIGlobalVariable(name: "hash_keys", scope: !2, file: !168, line: 69, type: !169, isLocal: false, isDefinition: true)
!183 = !DIGlobalVariableExpression(var: !184, expr: !DIExpression())
!184 = distinct !DIGlobalVariable(name: "source_mac", scope: !2, file: !185, line: 19, type: !65, isLocal: false, isDefinition: true)
!185 = !DIFile(filename: "./encap.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!186 = !DIGlobalVariableExpression(var: !187, expr: !DIExpression())
!187 = distinct !DIGlobalVariable(name: "gateway_mac", scope: !2, file: !185, line: 20, type: !65, isLocal: false, isDefinition: true)
!188 = !DIGlobalVariableExpression(var: !189, expr: !DIExpression())
!189 = distinct !DIGlobalVariable(name: "_license", scope: !2, file: !3, line: 251, type: !190, isLocal: false, isDefinition: true)
!190 = !DICompositeType(tag: DW_TAG_array_type, baseType: !191, size: 32, elements: !154)
!191 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!192 = !DIGlobalVariableExpression(var: !193, expr: !DIExpression())
!193 = distinct !DIGlobalVariable(name: "stdin", scope: !2, file: !194, line: 137, type: !195, isLocal: false, isDefinition: false)
!194 = !DIFile(filename: "/usr/include/stdio.h", directory: "")
!195 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !196, size: 64)
!196 = !DIDerivedType(tag: DW_TAG_typedef, name: "FILE", file: !197, line: 7, baseType: !198)
!197 = !DIFile(filename: "/usr/include/bits/types/FILE.h", directory: "")
!198 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_FILE", file: !199, line: 49, size: 1728, elements: !200)
!199 = !DIFile(filename: "/usr/include/bits/types/struct_FILE.h", directory: "")
!200 = !{!201, !202, !204, !205, !206, !207, !208, !209, !210, !211, !212, !213, !214, !217, !219, !220, !221, !223, !224, !226, !230, !233, !237, !240, !243, !244, !245, !249, !250}
!201 = !DIDerivedType(tag: DW_TAG_member, name: "_flags", scope: !198, file: !199, line: 51, baseType: !59, size: 32)
!202 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_ptr", scope: !198, file: !199, line: 54, baseType: !203, size: 64, offset: 64)
!203 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !191, size: 64)
!204 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_end", scope: !198, file: !199, line: 55, baseType: !203, size: 64, offset: 128)
!205 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_read_base", scope: !198, file: !199, line: 56, baseType: !203, size: 64, offset: 192)
!206 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_base", scope: !198, file: !199, line: 57, baseType: !203, size: 64, offset: 256)
!207 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_ptr", scope: !198, file: !199, line: 58, baseType: !203, size: 64, offset: 320)
!208 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_write_end", scope: !198, file: !199, line: 59, baseType: !203, size: 64, offset: 384)
!209 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_base", scope: !198, file: !199, line: 60, baseType: !203, size: 64, offset: 448)
!210 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_buf_end", scope: !198, file: !199, line: 61, baseType: !203, size: 64, offset: 512)
!211 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_base", scope: !198, file: !199, line: 64, baseType: !203, size: 64, offset: 576)
!212 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_backup_base", scope: !198, file: !199, line: 65, baseType: !203, size: 64, offset: 640)
!213 = !DIDerivedType(tag: DW_TAG_member, name: "_IO_save_end", scope: !198, file: !199, line: 66, baseType: !203, size: 64, offset: 704)
!214 = !DIDerivedType(tag: DW_TAG_member, name: "_markers", scope: !198, file: !199, line: 68, baseType: !215, size: 64, offset: 768)
!215 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !216, size: 64)
!216 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_marker", file: !199, line: 36, flags: DIFlagFwdDecl)
!217 = !DIDerivedType(tag: DW_TAG_member, name: "_chain", scope: !198, file: !199, line: 70, baseType: !218, size: 64, offset: 832)
!218 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !198, size: 64)
!219 = !DIDerivedType(tag: DW_TAG_member, name: "_fileno", scope: !198, file: !199, line: 72, baseType: !59, size: 32, offset: 896)
!220 = !DIDerivedType(tag: DW_TAG_member, name: "_flags2", scope: !198, file: !199, line: 73, baseType: !59, size: 32, offset: 928)
!221 = !DIDerivedType(tag: DW_TAG_member, name: "_old_offset", scope: !198, file: !199, line: 74, baseType: !222, size: 64, offset: 960)
!222 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off_t", file: !80, line: 152, baseType: !58)
!223 = !DIDerivedType(tag: DW_TAG_member, name: "_cur_column", scope: !198, file: !199, line: 77, baseType: !75, size: 16, offset: 1024)
!224 = !DIDerivedType(tag: DW_TAG_member, name: "_vtable_offset", scope: !198, file: !199, line: 78, baseType: !225, size: 8, offset: 1040)
!225 = !DIBasicType(name: "signed char", size: 8, encoding: DW_ATE_signed_char)
!226 = !DIDerivedType(tag: DW_TAG_member, name: "_shortbuf", scope: !198, file: !199, line: 79, baseType: !227, size: 8, offset: 1048)
!227 = !DICompositeType(tag: DW_TAG_array_type, baseType: !191, size: 8, elements: !228)
!228 = !{!229}
!229 = !DISubrange(count: 1)
!230 = !DIDerivedType(tag: DW_TAG_member, name: "_lock", scope: !198, file: !199, line: 81, baseType: !231, size: 64, offset: 1088)
!231 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !232, size: 64)
!232 = !DIDerivedType(tag: DW_TAG_typedef, name: "_IO_lock_t", file: !199, line: 43, baseType: null)
!233 = !DIDerivedType(tag: DW_TAG_member, name: "_offset", scope: !198, file: !199, line: 89, baseType: !234, size: 64, offset: 1152)
!234 = !DIDerivedType(tag: DW_TAG_typedef, name: "__off64_t", file: !80, line: 153, baseType: !235)
!235 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !80, line: 47, baseType: !236)
!236 = !DIBasicType(name: "long long int", size: 64, encoding: DW_ATE_signed)
!237 = !DIDerivedType(tag: DW_TAG_member, name: "_codecvt", scope: !198, file: !199, line: 91, baseType: !238, size: 64, offset: 1216)
!238 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !239, size: 64)
!239 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_codecvt", file: !199, line: 37, flags: DIFlagFwdDecl)
!240 = !DIDerivedType(tag: DW_TAG_member, name: "_wide_data", scope: !198, file: !199, line: 92, baseType: !241, size: 64, offset: 1280)
!241 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !242, size: 64)
!242 = !DICompositeType(tag: DW_TAG_structure_type, name: "_IO_wide_data", file: !199, line: 38, flags: DIFlagFwdDecl)
!243 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_list", scope: !198, file: !199, line: 93, baseType: !218, size: 64, offset: 1344)
!244 = !DIDerivedType(tag: DW_TAG_member, name: "_freeres_buf", scope: !198, file: !199, line: 94, baseType: !57, size: 64, offset: 1408)
!245 = !DIDerivedType(tag: DW_TAG_member, name: "__pad5", scope: !198, file: !199, line: 95, baseType: !246, size: 64, offset: 1472)
!246 = !DIDerivedType(tag: DW_TAG_typedef, name: "size_t", file: !247, line: 46, baseType: !248)
!247 = !DIFile(filename: "/usr/lib64/clang/13.0.0/include/stddef.h", directory: "")
!248 = !DIBasicType(name: "long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!249 = !DIDerivedType(tag: DW_TAG_member, name: "_mode", scope: !198, file: !199, line: 96, baseType: !59, size: 32, offset: 1536)
!250 = !DIDerivedType(tag: DW_TAG_member, name: "_unused2", scope: !198, file: !199, line: 98, baseType: !251, size: 160, offset: 1568)
!251 = !DICompositeType(tag: DW_TAG_array_type, baseType: !191, size: 160, elements: !252)
!252 = !{!253}
!253 = !DISubrange(count: 20)
!254 = !DIGlobalVariableExpression(var: !255, expr: !DIExpression())
!255 = distinct !DIGlobalVariable(name: "stdout", scope: !2, file: !194, line: 138, type: !195, isLocal: false, isDefinition: false)
!256 = !DIGlobalVariableExpression(var: !257, expr: !DIExpression())
!257 = distinct !DIGlobalVariable(name: "bpf_trace_printk", scope: !2, file: !258, line: 170, type: !259, isLocal: true, isDefinition: true)
!258 = !DIFile(filename: "/usr/include/bpf/bpf_helper_defs.h", directory: "")
!259 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !260, size: 64)
!260 = !DISubroutineType(types: !261)
!261 = !{!58, !262, !98, null}
!262 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !263, size: 64)
!263 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !191)
!264 = !DIGlobalVariableExpression(var: !265, expr: !DIExpression())
!265 = distinct !DIGlobalVariable(name: "bpf_xdp_adjust_head", scope: !2, file: !258, line: 1118, type: !266, isLocal: true, isDefinition: true)
!266 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !267, size: 64)
!267 = !DISubroutineType(types: !268)
!268 = !{!58, !269, !59}
!269 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !270, size: 64)
!270 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "xdp_md", file: !6, line: 5337, size: 192, elements: !271)
!271 = !{!272, !273, !274, !275, !276, !277}
!272 = !DIDerivedType(tag: DW_TAG_member, name: "data", scope: !270, file: !6, line: 5338, baseType: !98, size: 32)
!273 = !DIDerivedType(tag: DW_TAG_member, name: "data_end", scope: !270, file: !6, line: 5339, baseType: !98, size: 32, offset: 32)
!274 = !DIDerivedType(tag: DW_TAG_member, name: "data_meta", scope: !270, file: !6, line: 5340, baseType: !98, size: 32, offset: 64)
!275 = !DIDerivedType(tag: DW_TAG_member, name: "ingress_ifindex", scope: !270, file: !6, line: 5342, baseType: !98, size: 32, offset: 96)
!276 = !DIDerivedType(tag: DW_TAG_member, name: "rx_queue_index", scope: !270, file: !6, line: 5343, baseType: !98, size: 32, offset: 128)
!277 = !DIDerivedType(tag: DW_TAG_member, name: "egress_ifindex", scope: !270, file: !6, line: 5345, baseType: !98, size: 32, offset: 160)
!278 = !DIGlobalVariableExpression(var: !279, expr: !DIExpression())
!279 = distinct !DIGlobalVariable(name: "bpf_fib_lookup", scope: !2, file: !258, line: 1814, type: !280, isLocal: true, isDefinition: true)
!280 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !281, size: 64)
!281 = !DISubroutineType(types: !282)
!282 = !{!58, !57, !283, !59, !98}
!283 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !284, size: 64)
!284 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "bpf_fib_lookup", file: !6, line: 5947, size: 512, elements: !285)
!285 = !{!286, !287, !288, !289, !290, !295, !296, !302, !308, !313, !314, !315, !317}
!286 = !DIDerivedType(tag: DW_TAG_member, name: "family", scope: !284, file: !6, line: 5951, baseType: !86, size: 8)
!287 = !DIDerivedType(tag: DW_TAG_member, name: "l4_protocol", scope: !284, file: !6, line: 5954, baseType: !86, size: 8, offset: 8)
!288 = !DIDerivedType(tag: DW_TAG_member, name: "sport", scope: !284, file: !6, line: 5955, baseType: !71, size: 16, offset: 16)
!289 = !DIDerivedType(tag: DW_TAG_member, name: "dport", scope: !284, file: !6, line: 5956, baseType: !71, size: 16, offset: 32)
!290 = !DIDerivedType(tag: DW_TAG_member, scope: !284, file: !6, line: 5958, baseType: !291, size: 16, offset: 48)
!291 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !284, file: !6, line: 5958, size: 16, elements: !292)
!292 = !{!293, !294}
!293 = !DIDerivedType(tag: DW_TAG_member, name: "tot_len", scope: !291, file: !6, line: 5960, baseType: !73, size: 16)
!294 = !DIDerivedType(tag: DW_TAG_member, name: "mtu_result", scope: !291, file: !6, line: 5963, baseType: !73, size: 16)
!295 = !DIDerivedType(tag: DW_TAG_member, name: "ifindex", scope: !284, file: !6, line: 5968, baseType: !98, size: 32, offset: 64)
!296 = !DIDerivedType(tag: DW_TAG_member, scope: !284, file: !6, line: 5970, baseType: !297, size: 32, offset: 96)
!297 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !284, file: !6, line: 5970, size: 32, elements: !298)
!298 = !{!299, !300, !301}
!299 = !DIDerivedType(tag: DW_TAG_member, name: "tos", scope: !297, file: !6, line: 5972, baseType: !86, size: 8)
!300 = !DIDerivedType(tag: DW_TAG_member, name: "flowinfo", scope: !297, file: !6, line: 5973, baseType: !97, size: 32)
!301 = !DIDerivedType(tag: DW_TAG_member, name: "rt_metric", scope: !297, file: !6, line: 5976, baseType: !98, size: 32)
!302 = !DIDerivedType(tag: DW_TAG_member, scope: !284, file: !6, line: 5979, baseType: !303, size: 128, offset: 128)
!303 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !284, file: !6, line: 5979, size: 128, elements: !304)
!304 = !{!305, !306}
!305 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_src", scope: !303, file: !6, line: 5980, baseType: !97, size: 32)
!306 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_src", scope: !303, file: !6, line: 5981, baseType: !307, size: 128)
!307 = !DICompositeType(tag: DW_TAG_array_type, baseType: !98, size: 128, elements: !154)
!308 = !DIDerivedType(tag: DW_TAG_member, scope: !284, file: !6, line: 5988, baseType: !309, size: 128, offset: 256)
!309 = distinct !DICompositeType(tag: DW_TAG_union_type, scope: !284, file: !6, line: 5988, size: 128, elements: !310)
!310 = !{!311, !312}
!311 = !DIDerivedType(tag: DW_TAG_member, name: "ipv4_dst", scope: !309, file: !6, line: 5989, baseType: !97, size: 32)
!312 = !DIDerivedType(tag: DW_TAG_member, name: "ipv6_dst", scope: !309, file: !6, line: 5990, baseType: !307, size: 128)
!313 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_proto", scope: !284, file: !6, line: 5994, baseType: !71, size: 16, offset: 384)
!314 = !DIDerivedType(tag: DW_TAG_member, name: "h_vlan_TCI", scope: !284, file: !6, line: 5995, baseType: !71, size: 16, offset: 400)
!315 = !DIDerivedType(tag: DW_TAG_member, name: "smac", scope: !284, file: !6, line: 5996, baseType: !316, size: 48, offset: 416)
!316 = !DICompositeType(tag: DW_TAG_array_type, baseType: !86, size: 48, elements: !67)
!317 = !DIDerivedType(tag: DW_TAG_member, name: "dmac", scope: !284, file: !6, line: 5997, baseType: !316, size: 48, offset: 464)
!318 = !DIGlobalVariableExpression(var: !319, expr: !DIExpression())
!319 = distinct !DIGlobalVariable(name: "bpf_map_lookup_elem", scope: !2, file: !258, line: 49, type: !320, isLocal: true, isDefinition: true)
!320 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !321, size: 64)
!321 = !DISubroutineType(types: !322)
!322 = !{!57, !57, !323}
!323 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !324, size: 64)
!324 = !DIDerivedType(tag: DW_TAG_const_type, baseType: null)
!325 = !DIGlobalVariableExpression(var: !326, expr: !DIExpression())
!326 = distinct !DIGlobalVariable(name: "bpf_redirect_map", scope: !2, file: !258, line: 1294, type: !327, isLocal: true, isDefinition: true)
!327 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !328, size: 64)
!328 = !DISubroutineType(types: !329)
!329 = !{!58, !57, !98, !330}
!330 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u64", file: !74, line: 31, baseType: !159)
!331 = !{i32 7, !"Dwarf Version", i32 4}
!332 = !{i32 2, !"Debug Info Version", i32 3}
!333 = !{i32 1, !"wchar_size", i32 4}
!334 = !{i32 7, !"PIC Level", i32 2}
!335 = !{i32 7, !"frame-pointer", i32 2}
!336 = !{!"clang version 13.0.0 (Red Hat 13.0.0-2.el9)"}
!337 = distinct !DISubprogram(name: "balancer", scope: !3, file: !3, line: 237, type: !338, scopeLine: 238, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !340)
!338 = !DISubroutineType(types: !339)
!339 = !{!59, !269}
!340 = !{!341, !342}
!341 = !DILocalVariable(name: "ctx", arg: 1, scope: !337, file: !3, line: 237, type: !269)
!342 = !DILocalVariable(name: "____fmt", scope: !343, file: !3, line: 240, type: !344)
!343 = distinct !DILexicalBlock(scope: !337, file: !3, line: 240, column: 5)
!344 = !DICompositeType(tag: DW_TAG_array_type, baseType: !191, size: 80, elements: !345)
!345 = !{!346}
!346 = !DISubrange(count: 10)
!347 = !DILocation(line: 0, scope: !337)
!348 = !DILocation(line: 240, column: 5, scope: !343)
!349 = !DILocation(line: 240, column: 5, scope: !337)
!350 = !DILocalVariable(name: "ctx", arg: 1, scope: !351, file: !3, line: 12, type: !269)
!351 = distinct !DISubprogram(name: "process_packet", scope: !3, file: !3, line: 12, type: !338, scopeLine: 13, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !352)
!352 = !{!350, !353, !355, !359, !360, !361, !362, !363, !364, !388, !391, !398, !399, !404, !422, !423, !424, !425, !426, !434, !435, !445, !446, !447}
!353 = !DILocalVariable(name: "fmt", scope: !351, file: !3, line: 14, type: !354)
!354 = !DICompositeType(tag: DW_TAG_array_type, baseType: !263, size: 24, elements: !132)
!355 = !DILocalVariable(name: "fmt1", scope: !351, file: !3, line: 15, type: !356)
!356 = !DICompositeType(tag: DW_TAG_array_type, baseType: !263, size: 40, elements: !357)
!357 = !{!358}
!358 = !DISubrange(count: 5)
!359 = !DILocalVariable(name: "action", scope: !351, file: !3, line: 19, type: !98)
!360 = !DILocalVariable(name: "data", scope: !351, file: !3, line: 29, type: !57)
!361 = !DILocalVariable(name: "data_end", scope: !351, file: !3, line: 30, type: !57)
!362 = !DILocalVariable(name: "ip4_hdr", scope: !351, file: !3, line: 32, type: !81)
!363 = !DILocalVariable(name: "port", scope: !351, file: !3, line: 37, type: !164)
!364 = !DILocalVariable(name: "tcp_hdr", scope: !365, file: !3, line: 39, type: !367)
!365 = distinct !DILexicalBlock(scope: !366, file: !3, line: 38, column: 33)
!366 = distinct !DILexicalBlock(scope: !351, file: !3, line: 38, column: 9)
!367 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !368, size: 64)
!368 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tcphdr", file: !369, line: 25, size: 160, elements: !370)
!369 = !DIFile(filename: "/usr/include/linux/tcp.h", directory: "")
!370 = !{!371, !372, !373, !374, !375, !376, !377, !378, !379, !380, !381, !382, !383, !384, !385, !386, !387}
!371 = !DIDerivedType(tag: DW_TAG_member, name: "source", scope: !368, file: !369, line: 26, baseType: !71, size: 16)
!372 = !DIDerivedType(tag: DW_TAG_member, name: "dest", scope: !368, file: !369, line: 27, baseType: !71, size: 16, offset: 16)
!373 = !DIDerivedType(tag: DW_TAG_member, name: "seq", scope: !368, file: !369, line: 28, baseType: !97, size: 32, offset: 32)
!374 = !DIDerivedType(tag: DW_TAG_member, name: "ack_seq", scope: !368, file: !369, line: 29, baseType: !97, size: 32, offset: 64)
!375 = !DIDerivedType(tag: DW_TAG_member, name: "res1", scope: !368, file: !369, line: 31, baseType: !73, size: 4, offset: 96, flags: DIFlagBitField, extraData: i64 96)
!376 = !DIDerivedType(tag: DW_TAG_member, name: "doff", scope: !368, file: !369, line: 32, baseType: !73, size: 4, offset: 100, flags: DIFlagBitField, extraData: i64 96)
!377 = !DIDerivedType(tag: DW_TAG_member, name: "fin", scope: !368, file: !369, line: 33, baseType: !73, size: 1, offset: 104, flags: DIFlagBitField, extraData: i64 96)
!378 = !DIDerivedType(tag: DW_TAG_member, name: "syn", scope: !368, file: !369, line: 34, baseType: !73, size: 1, offset: 105, flags: DIFlagBitField, extraData: i64 96)
!379 = !DIDerivedType(tag: DW_TAG_member, name: "rst", scope: !368, file: !369, line: 35, baseType: !73, size: 1, offset: 106, flags: DIFlagBitField, extraData: i64 96)
!380 = !DIDerivedType(tag: DW_TAG_member, name: "psh", scope: !368, file: !369, line: 36, baseType: !73, size: 1, offset: 107, flags: DIFlagBitField, extraData: i64 96)
!381 = !DIDerivedType(tag: DW_TAG_member, name: "ack", scope: !368, file: !369, line: 37, baseType: !73, size: 1, offset: 108, flags: DIFlagBitField, extraData: i64 96)
!382 = !DIDerivedType(tag: DW_TAG_member, name: "urg", scope: !368, file: !369, line: 38, baseType: !73, size: 1, offset: 109, flags: DIFlagBitField, extraData: i64 96)
!383 = !DIDerivedType(tag: DW_TAG_member, name: "ece", scope: !368, file: !369, line: 39, baseType: !73, size: 1, offset: 110, flags: DIFlagBitField, extraData: i64 96)
!384 = !DIDerivedType(tag: DW_TAG_member, name: "cwr", scope: !368, file: !369, line: 40, baseType: !73, size: 1, offset: 111, flags: DIFlagBitField, extraData: i64 96)
!385 = !DIDerivedType(tag: DW_TAG_member, name: "window", scope: !368, file: !369, line: 55, baseType: !71, size: 16, offset: 112)
!386 = !DIDerivedType(tag: DW_TAG_member, name: "check", scope: !368, file: !369, line: 56, baseType: !95, size: 16, offset: 128)
!387 = !DIDerivedType(tag: DW_TAG_member, name: "urg_ptr", scope: !368, file: !369, line: 57, baseType: !71, size: 16, offset: 144)
!388 = !DILocalVariable(name: "udp_hdr", scope: !389, file: !3, line: 44, type: !100)
!389 = distinct !DILexicalBlock(scope: !390, file: !3, line: 43, column: 41)
!390 = distinct !DILexicalBlock(scope: !366, file: !3, line: 43, column: 16)
!391 = !DILocalVariable(name: "binds_key", scope: !351, file: !3, line: 52, type: !392)
!392 = !DIDerivedType(tag: DW_TAG_typedef, name: "binds_row_key", file: !168, line: 117, baseType: !393)
!393 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !168, line: 113, size: 56, elements: !394)
!394 = !{!395, !396, !397}
!395 = !DIDerivedType(tag: DW_TAG_member, name: "ip", scope: !393, file: !168, line: 114, baseType: !160, size: 32)
!396 = !DIDerivedType(tag: DW_TAG_member, name: "port", scope: !393, file: !168, line: 115, baseType: !164, size: 16, offset: 32)
!397 = !DIDerivedType(tag: DW_TAG_member, name: "protocol", scope: !393, file: !168, line: 116, baseType: !77, size: 8, offset: 48)
!398 = !DILocalVariable(name: "backends_key", scope: !351, file: !3, line: 60, type: !160)
!399 = !DILocalVariable(name: "____fmt", scope: !400, file: !3, line: 65, type: !401)
!400 = distinct !DILexicalBlock(scope: !351, file: !3, line: 65, column: 5)
!401 = !DICompositeType(tag: DW_TAG_array_type, baseType: !191, size: 280, elements: !402)
!402 = !{!403}
!403 = !DISubrange(count: 35)
!404 = !DILocalVariable(name: "c", scope: !351, file: !3, line: 68, type: !405)
!405 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !406, size: 64)
!406 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "packet_context", file: !407, line: 24, size: 704, elements: !408)
!407 = !DIFile(filename: "./../common/parsing_helpers.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!408 = !{!409, !410, !411, !413, !414, !415, !416, !417, !418, !419, !420, !421}
!409 = !DIDerivedType(tag: DW_TAG_member, name: "packet_start", scope: !406, file: !407, line: 25, baseType: !76, size: 64)
!410 = !DIDerivedType(tag: DW_TAG_member, name: "packet_end", scope: !406, file: !407, line: 26, baseType: !76, size: 64, offset: 64)
!411 = !DIDerivedType(tag: DW_TAG_member, name: "backends_key", scope: !406, file: !407, line: 27, baseType: !412, size: 64, offset: 128)
!412 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !160, size: 64)
!413 = !DIDerivedType(tag: DW_TAG_member, name: "orig_eth_type", scope: !406, file: !407, line: 28, baseType: !73, size: 16, offset: 192)
!414 = !DIDerivedType(tag: DW_TAG_member, name: "orig_ip_type", scope: !406, file: !407, line: 29, baseType: !164, size: 16, offset: 208)
!415 = !DIDerivedType(tag: DW_TAG_member, name: "orig_ip4_hdr", scope: !406, file: !407, line: 30, baseType: !81, size: 64, offset: 256)
!416 = !DIDerivedType(tag: DW_TAG_member, name: "orig_ip6_hdr", scope: !406, file: !407, line: 31, baseType: !124, size: 64, offset: 320)
!417 = !DIDerivedType(tag: DW_TAG_member, name: "eth_hdr", scope: !406, file: !407, line: 32, baseType: !60, size: 64, offset: 384)
!418 = !DIDerivedType(tag: DW_TAG_member, name: "dest_ip4", scope: !406, file: !407, line: 33, baseType: !98, size: 32, offset: 448)
!419 = !DIDerivedType(tag: DW_TAG_member, name: "ip4_hdr", scope: !406, file: !407, line: 34, baseType: !81, size: 64, offset: 512)
!420 = !DIDerivedType(tag: DW_TAG_member, name: "gue_hdr", scope: !406, file: !407, line: 35, baseType: !108, size: 64, offset: 576)
!421 = !DIDerivedType(tag: DW_TAG_member, name: "udp_hdr", scope: !406, file: !407, line: 36, baseType: !100, size: 64, offset: 640)
!422 = !DILocalVariable(name: "ok", scope: !351, file: !3, line: 74, type: !59)
!423 = !DILocalVariable(name: "hashingKey1", scope: !351, file: !3, line: 106, type: !157)
!424 = !DILocalVariable(name: "hashingKey2", scope: !351, file: !3, line: 107, type: !157)
!425 = !DILocalVariable(name: "hash", scope: !351, file: !3, line: 108, type: !157)
!426 = !DILocalVariable(name: "backends_row", scope: !351, file: !3, line: 109, type: !427)
!427 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !428, size: 64)
!428 = !DIDerivedType(tag: DW_TAG_typedef, name: "bind_backends_row", file: !168, line: 101, baseType: !429)
!429 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !168, line: 99, size: 64, elements: !430)
!430 = !{!431}
!431 = !DIDerivedType(tag: DW_TAG_member, name: "rows", scope: !429, file: !168, line: 100, baseType: !432, size: 64)
!432 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !433, size: 64)
!433 = !DICompositeType(tag: DW_TAG_structure_type, name: "bind_backends_inner_row", file: !168, line: 100, flags: DIFlagFwdDecl)
!434 = !DILocalVariable(name: "hashToIndex", scope: !351, file: !3, line: 113, type: !160)
!435 = !DILocalVariable(name: "backends_inner_row", scope: !351, file: !3, line: 119, type: !436)
!436 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !437, size: 64)
!437 = !DIDerivedType(tag: DW_TAG_typedef, name: "bind_backends_inner_row", file: !168, line: 94, baseType: !438)
!438 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !168, line: 91, size: 32, elements: !439)
!439 = !{!440, !441}
!440 = !DIDerivedType(tag: DW_TAG_member, name: "ethernetIndex", scope: !438, file: !168, line: 92, baseType: !160, size: 32)
!441 = !DIDerivedType(tag: DW_TAG_member, name: "ips", scope: !438, file: !168, line: 93, baseType: !442, offset: 32)
!442 = !DICompositeType(tag: DW_TAG_array_type, baseType: !160, elements: !443)
!443 = !{!444}
!444 = !DISubrange(count: -1)
!445 = !DILocalVariable(name: "fib_params", scope: !351, file: !3, line: 181, type: !284)
!446 = !DILocalVariable(name: "rc", scope: !351, file: !3, line: 193, type: !59)
!447 = !DILabel(scope: !351, name: "out", file: !3, line: 231)
!448 = !DILocation(line: 0, scope: !351, inlinedAt: !449)
!449 = distinct !DILocation(line: 242, column: 12, scope: !337)
!450 = !DILocation(line: 29, column: 37, scope: !351, inlinedAt: !449)
!451 = !{!452, !453, i64 0}
!452 = !{!"xdp_md", !453, i64 0, !453, i64 4, !453, i64 8, !453, i64 12, !453, i64 16, !453, i64 20}
!453 = !{!"int", !454, i64 0}
!454 = !{!"omnipotent char", !455, i64 0}
!455 = !{!"Simple C/C++ TBAA"}
!456 = !DILocation(line: 29, column: 26, scope: !351, inlinedAt: !449)
!457 = !DILocation(line: 29, column: 18, scope: !351, inlinedAt: !449)
!458 = !DILocation(line: 30, column: 41, scope: !351, inlinedAt: !449)
!459 = !{!452, !453, i64 4}
!460 = !DILocation(line: 30, column: 30, scope: !351, inlinedAt: !449)
!461 = !DILocation(line: 33, column: 17, scope: !462, inlinedAt: !449)
!462 = distinct !DILexicalBlock(scope: !351, file: !3, line: 33, column: 9)
!463 = !DILocation(line: 33, column: 23, scope: !462, inlinedAt: !449)
!464 = !DILocation(line: 33, column: 21, scope: !462, inlinedAt: !449)
!465 = !DILocation(line: 33, column: 9, scope: !351, inlinedAt: !449)
!466 = !DILocation(line: 38, column: 18, scope: !366, inlinedAt: !449)
!467 = !{!468, !454, i64 9}
!468 = !{!"iphdr", !454, i64 0, !454, i64 0, !454, i64 1, !469, i64 2, !469, i64 4, !469, i64 6, !454, i64 8, !454, i64 9, !469, i64 10, !453, i64 12, !453, i64 16}
!469 = !{!"short", !454, i64 0}
!470 = !DILocation(line: 38, column: 9, scope: !351, inlinedAt: !449)
!471 = !DILocation(line: 0, scope: !365, inlinedAt: !449)
!472 = !DILocation(line: 40, column: 21, scope: !473, inlinedAt: !449)
!473 = distinct !DILexicalBlock(scope: !365, file: !3, line: 40, column: 13)
!474 = !DILocation(line: 40, column: 27, scope: !473, inlinedAt: !449)
!475 = !DILocation(line: 40, column: 25, scope: !473, inlinedAt: !449)
!476 = !DILocation(line: 40, column: 13, scope: !365, inlinedAt: !449)
!477 = !DILocation(line: 0, scope: !389, inlinedAt: !449)
!478 = !DILocation(line: 45, column: 21, scope: !479, inlinedAt: !449)
!479 = distinct !DILexicalBlock(scope: !389, file: !3, line: 45, column: 13)
!480 = !DILocation(line: 45, column: 27, scope: !479, inlinedAt: !449)
!481 = !DILocation(line: 45, column: 25, scope: !479, inlinedAt: !449)
!482 = !DILocation(line: 45, column: 13, scope: !389, inlinedAt: !449)
!483 = !DILocation(line: 0, scope: !366, inlinedAt: !449)
!484 = !DILocation(line: 52, column: 5, scope: !351, inlinedAt: !449)
!485 = !DILocation(line: 52, column: 19, scope: !351, inlinedAt: !449)
!486 = !DILocation(line: 52, column: 31, scope: !351, inlinedAt: !449)
!487 = !DILocation(line: 53, column: 40, scope: !351, inlinedAt: !449)
!488 = !{!468, !453, i64 16}
!489 = !DILocalVariable(name: "__bsx", arg: 1, scope: !490, file: !491, line: 49, type: !161)
!490 = distinct !DISubprogram(name: "__bswap_32", scope: !491, file: !491, line: 49, type: !492, scopeLine: 50, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !494)
!491 = !DIFile(filename: "/usr/include/bits/byteswap.h", directory: "")
!492 = !DISubroutineType(types: !493)
!493 = !{!161, !161}
!494 = !{!489}
!495 = !DILocation(line: 0, scope: !490, inlinedAt: !496)
!496 = distinct !DILocation(line: 53, column: 20, scope: !351, inlinedAt: !449)
!497 = !DILocation(line: 54, column: 10, scope: !490, inlinedAt: !496)
!498 = !{!499, !453, i64 0}
!499 = !{!"", !453, i64 0, !469, i64 4, !454, i64 6}
!500 = !{!499, !469, i64 4}
!501 = !{!499, !454, i64 6}
!502 = !DILocation(line: 60, column: 5, scope: !351, inlinedAt: !449)
!503 = !DILocalVariable(name: "row_key", arg: 1, scope: !504, file: !505, line: 26, type: !508)
!504 = distinct !DISubprogram(name: "get_binds_row", scope: !505, file: !505, line: 26, type: !506, scopeLine: 26, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !509)
!505 = !DIFile(filename: "./map_utils.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!506 = !DISubroutineType(types: !507)
!507 = !{!160, !508}
!508 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !392, size: 64)
!509 = !{!503, !510, !511, !512, !513, !514}
!510 = !DILocalVariable(name: "hashingKey1", scope: !504, file: !505, line: 27, type: !157)
!511 = !DILocalVariable(name: "hashingKey2", scope: !504, file: !505, line: 28, type: !157)
!512 = !DILocalVariable(name: "hash", scope: !504, file: !505, line: 29, type: !157)
!513 = !DILocalVariable(name: "reversed_hash", scope: !504, file: !505, line: 34, type: !157)
!514 = !DILocalVariable(name: "res", scope: !504, file: !505, line: 35, type: !412)
!515 = !DILocation(line: 0, scope: !504, inlinedAt: !516)
!516 = distinct !DILocation(line: 60, column: 29, scope: !351, inlinedAt: !449)
!517 = !DILocation(line: 29, column: 5, scope: !504, inlinedAt: !516)
!518 = !DILocation(line: 31, column: 5, scope: !504, inlinedAt: !516)
!519 = !DILocation(line: 34, column: 5, scope: !504, inlinedAt: !516)
!520 = !DILocation(line: 34, column: 41, scope: !504, inlinedAt: !516)
!521 = !{!522, !522, i64 0}
!522 = !{!"long long", !454, i64 0}
!523 = !DILocalVariable(name: "__bsx", arg: 1, scope: !524, file: !491, line: 70, type: !158)
!524 = distinct !DISubprogram(name: "__bswap_64", scope: !491, file: !491, line: 70, type: !525, scopeLine: 71, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !527)
!525 = !DISubroutineType(types: !526)
!526 = !{!158, !158}
!527 = !{!523}
!528 = !DILocation(line: 0, scope: !524, inlinedAt: !529)
!529 = distinct !DILocation(line: 34, column: 30, scope: !504, inlinedAt: !516)
!530 = !DILocation(line: 75, column: 10, scope: !524, inlinedAt: !529)
!531 = !DILocation(line: 34, column: 14, scope: !504, inlinedAt: !516)
!532 = !DILocation(line: 35, column: 21, scope: !504, inlinedAt: !516)
!533 = !DILocation(line: 36, column: 13, scope: !534, inlinedAt: !516)
!534 = distinct !DILexicalBlock(scope: !504, file: !505, line: 36, column: 9)
!535 = !DILocation(line: 36, column: 9, scope: !504, inlinedAt: !516)
!536 = !DILocation(line: 38, column: 1, scope: !504, inlinedAt: !516)
!537 = !DILocation(line: 62, column: 9, scope: !351, inlinedAt: !449)
!538 = !DILocation(line: 37, column: 12, scope: !504, inlinedAt: !516)
!539 = !{!453, !453, i64 0}
!540 = !DILocation(line: 60, column: 14, scope: !351, inlinedAt: !449)
!541 = !DILocation(line: 62, column: 22, scope: !542, inlinedAt: !449)
!542 = distinct !DILexicalBlock(scope: !351, file: !3, line: 62, column: 9)
!543 = !DILocation(line: 65, column: 5, scope: !400, inlinedAt: !449)
!544 = !DILocation(line: 65, column: 5, scope: !351, inlinedAt: !449)
!545 = !DILocation(line: 69, column: 42, scope: !351, inlinedAt: !449)
!546 = !DILocation(line: 69, column: 31, scope: !351, inlinedAt: !449)
!547 = !DILocation(line: 70, column: 40, scope: !351, inlinedAt: !449)
!548 = !DILocation(line: 70, column: 29, scope: !351, inlinedAt: !449)
!549 = !DILocation(line: 70, column: 21, scope: !351, inlinedAt: !449)
!550 = !DILocalVariable(name: "c", arg: 1, scope: !551, file: !407, line: 45, type: !405)
!551 = distinct !DISubprogram(name: "parse_packet", scope: !407, file: !407, line: 45, type: !552, scopeLine: 45, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !554)
!552 = !DISubroutineType(types: !553)
!553 = !{!59, !405}
!554 = !{!550, !555, !558, !559}
!555 = !DILocalVariable(name: "eth_hdr", scope: !551, file: !407, line: 47, type: !556)
!556 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !557, size: 64)
!557 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !61)
!558 = !DILocalVariable(name: "ip6_hdr", scope: !551, file: !407, line: 53, type: !124)
!559 = !DILocalVariable(name: "ip4_hdr", scope: !551, file: !407, line: 54, type: !81)
!560 = !DILocation(line: 0, scope: !551, inlinedAt: !561)
!561 = distinct !DILocation(line: 74, column: 14, scope: !351, inlinedAt: !449)
!562 = !DILocation(line: 48, column: 5, scope: !563, inlinedAt: !561)
!563 = distinct !DILexicalBlock(scope: !551, file: !407, line: 48, column: 5)
!564 = !DILocation(line: 48, column: 5, scope: !565, inlinedAt: !561)
!565 = distinct !DILexicalBlock(scope: !563, file: !407, line: 48, column: 5)
!566 = !DILocation(line: 49, column: 24, scope: !551, inlinedAt: !561)
!567 = !{!568, !469, i64 12}
!568 = !{!"ethhdr", !454, i64 0, !454, i64 6, !469, i64 12}
!569 = !DILocation(line: 55, column: 5, scope: !551, inlinedAt: !561)
!570 = !DILocation(line: 60, column: 13, scope: !571, inlinedAt: !561)
!571 = distinct !DILexicalBlock(scope: !572, file: !407, line: 60, column: 13)
!572 = distinct !DILexicalBlock(scope: !573, file: !407, line: 60, column: 13)
!573 = distinct !DILexicalBlock(scope: !551, file: !407, line: 55, column: 31)
!574 = !DILocation(line: 60, column: 13, scope: !572, inlinedAt: !561)
!575 = !DILocation(line: 67, column: 13, scope: !576, inlinedAt: !561)
!576 = distinct !DILexicalBlock(scope: !577, file: !407, line: 67, column: 13)
!577 = distinct !DILexicalBlock(scope: !573, file: !407, line: 67, column: 13)
!578 = !DILocation(line: 67, column: 13, scope: !577, inlinedAt: !561)
!579 = !DILocation(line: 79, column: 10, scope: !351, inlinedAt: !449)
!580 = !DILocation(line: 80, column: 12, scope: !581, inlinedAt: !449)
!581 = distinct !DILexicalBlock(scope: !351, file: !3, line: 80, column: 9)
!582 = !DILocation(line: 80, column: 9, scope: !351, inlinedAt: !449)
!583 = !DILocation(line: 84, column: 42, scope: !351, inlinedAt: !449)
!584 = !DILocation(line: 84, column: 31, scope: !351, inlinedAt: !449)
!585 = !DILocation(line: 84, column: 23, scope: !351, inlinedAt: !449)
!586 = !DILocation(line: 85, column: 40, scope: !351, inlinedAt: !449)
!587 = !DILocation(line: 85, column: 29, scope: !351, inlinedAt: !449)
!588 = !DILocation(line: 85, column: 21, scope: !351, inlinedAt: !449)
!589 = !DILocation(line: 88, column: 5, scope: !590, inlinedAt: !449)
!590 = distinct !DILexicalBlock(scope: !351, file: !3, line: 88, column: 5)
!591 = !DILocation(line: 88, column: 5, scope: !592, inlinedAt: !449)
!592 = distinct !DILexicalBlock(scope: !590, file: !3, line: 88, column: 5)
!593 = !DILocation(line: 89, column: 26, scope: !594, inlinedAt: !449)
!594 = distinct !DILexicalBlock(scope: !351, file: !3, line: 89, column: 9)
!595 = !DILocation(line: 89, column: 24, scope: !594, inlinedAt: !449)
!596 = !DILocation(line: 89, column: 9, scope: !351, inlinedAt: !449)
!597 = !DILocation(line: 91, column: 5, scope: !598, inlinedAt: !449)
!598 = distinct !DILexicalBlock(scope: !351, file: !3, line: 91, column: 5)
!599 = !DILocation(line: 91, column: 5, scope: !600, inlinedAt: !449)
!600 = distinct !DILexicalBlock(scope: !598, file: !3, line: 91, column: 5)
!601 = !DILocation(line: 94, column: 5, scope: !602, inlinedAt: !449)
!602 = distinct !DILexicalBlock(scope: !603, file: !3, line: 94, column: 5)
!603 = distinct !DILexicalBlock(scope: !351, file: !3, line: 94, column: 5)
!604 = !DILocation(line: 94, column: 5, scope: !603, inlinedAt: !449)
!605 = !DILocation(line: 97, column: 5, scope: !606, inlinedAt: !449)
!606 = distinct !DILexicalBlock(scope: !607, file: !3, line: 97, column: 5)
!607 = distinct !DILexicalBlock(scope: !351, file: !3, line: 97, column: 5)
!608 = !DILocation(line: 97, column: 5, scope: !607, inlinedAt: !449)
!609 = !DILocation(line: 108, column: 5, scope: !351, inlinedAt: !449)
!610 = !DILocalVariable(name: "index", arg: 1, scope: !611, file: !505, line: 43, type: !412)
!611 = distinct !DISubprogram(name: "get_bind_backends_row", scope: !505, file: !505, line: 43, type: !612, scopeLine: 43, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !614)
!612 = !DISubroutineType(types: !613)
!613 = !{!427, !412}
!614 = !{!610, !615}
!615 = !DILocalVariable(name: "row", scope: !611, file: !505, line: 44, type: !427)
!616 = !DILocation(line: 0, scope: !611, inlinedAt: !617)
!617 = distinct !DILocation(line: 109, column: 39, scope: !351, inlinedAt: !449)
!618 = !DILocation(line: 44, column: 30, scope: !611, inlinedAt: !617)
!619 = !DILocation(line: 110, column: 22, scope: !620, inlinedAt: !449)
!620 = distinct !DILexicalBlock(scope: !351, file: !3, line: 110, column: 9)
!621 = !DILocation(line: 110, column: 9, scope: !351, inlinedAt: !449)
!622 = !DILocation(line: 111, column: 42, scope: !351, inlinedAt: !449)
!623 = !DILocation(line: 111, column: 5, scope: !351, inlinedAt: !449)
!624 = !DILocation(line: 113, column: 5, scope: !351, inlinedAt: !449)
!625 = !DILocation(line: 113, column: 28, scope: !351, inlinedAt: !449)
!626 = !DILocation(line: 113, column: 14, scope: !351, inlinedAt: !449)
!627 = !DILocalVariable(name: "row", arg: 1, scope: !628, file: !505, line: 53, type: !427)
!628 = distinct !DISubprogram(name: "get_bind_backends_inner_row", scope: !505, file: !505, line: 53, type: !629, scopeLine: 53, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !631)
!629 = !DISubroutineType(types: !630)
!630 = !{!436, !427, !412}
!631 = !{!627, !632, !633}
!632 = !DILocalVariable(name: "index", arg: 2, scope: !628, file: !505, line: 53, type: !412)
!633 = !DILocalVariable(name: "inner_row", scope: !628, file: !505, line: 54, type: !436)
!634 = !DILocation(line: 0, scope: !628, inlinedAt: !635)
!635 = distinct !DILocation(line: 119, column: 51, scope: !351, inlinedAt: !449)
!636 = !DILocation(line: 54, column: 42, scope: !628, inlinedAt: !635)
!637 = !DILocation(line: 120, column: 28, scope: !638, inlinedAt: !449)
!638 = distinct !DILexicalBlock(scope: !351, file: !3, line: 120, column: 9)
!639 = !DILocation(line: 120, column: 9, scope: !351, inlinedAt: !449)
!640 = !DILocation(line: 139, column: 5, scope: !351, inlinedAt: !449)
!641 = !DILocation(line: 141, column: 25, scope: !351, inlinedAt: !449)
!642 = !DILocation(line: 142, column: 17, scope: !351, inlinedAt: !449)
!643 = !DILocation(line: 142, column: 21, scope: !351, inlinedAt: !449)
!644 = !{!468, !454, i64 1}
!645 = !DILocation(line: 143, column: 27, scope: !351, inlinedAt: !449)
!646 = !DILocation(line: 143, column: 17, scope: !351, inlinedAt: !449)
!647 = !DILocation(line: 143, column: 25, scope: !351, inlinedAt: !449)
!648 = !{!468, !469, i64 2}
!649 = !DILocation(line: 144, column: 17, scope: !351, inlinedAt: !449)
!650 = !DILocation(line: 144, column: 20, scope: !351, inlinedAt: !449)
!651 = !{!468, !469, i64 4}
!652 = !DILocation(line: 145, column: 17, scope: !351, inlinedAt: !449)
!653 = !DILocation(line: 145, column: 26, scope: !351, inlinedAt: !449)
!654 = !{!468, !469, i64 6}
!655 = !DILocation(line: 146, column: 17, scope: !351, inlinedAt: !449)
!656 = !DILocation(line: 146, column: 21, scope: !351, inlinedAt: !449)
!657 = !{!468, !454, i64 8}
!658 = !DILocation(line: 147, column: 17, scope: !351, inlinedAt: !449)
!659 = !DILocation(line: 147, column: 26, scope: !351, inlinedAt: !449)
!660 = !DILocation(line: 148, column: 17, scope: !351, inlinedAt: !449)
!661 = !DILocation(line: 148, column: 23, scope: !351, inlinedAt: !449)
!662 = !{!468, !469, i64 10}
!663 = !DILocation(line: 149, column: 42, scope: !351, inlinedAt: !449)
!664 = !DILocation(line: 149, column: 17, scope: !351, inlinedAt: !449)
!665 = !DILocation(line: 149, column: 23, scope: !351, inlinedAt: !449)
!666 = !{!468, !453, i64 12}
!667 = !DILocation(line: 150, column: 25, scope: !351, inlinedAt: !449)
!668 = !DILocation(line: 150, column: 23, scope: !351, inlinedAt: !449)
!669 = !DILocation(line: 151, column: 25, scope: !351, inlinedAt: !449)
!670 = !DILocation(line: 151, column: 23, scope: !351, inlinedAt: !449)
!671 = !DILocation(line: 154, column: 5, scope: !351, inlinedAt: !449)
!672 = !DILocation(line: 157, column: 23, scope: !351, inlinedAt: !449)
!673 = !DILocation(line: 157, column: 17, scope: !351, inlinedAt: !449)
!674 = !DILocation(line: 157, column: 21, scope: !351, inlinedAt: !449)
!675 = !{!676, !469, i64 4}
!676 = !{!"udphdr", !469, i64 0, !469, i64 2, !469, i64 4, !469, i64 6}
!677 = !DILocation(line: 161, column: 5, scope: !351, inlinedAt: !449)
!678 = !DILocation(line: 181, column: 5, scope: !351, inlinedAt: !449)
!679 = !DILocation(line: 181, column: 27, scope: !351, inlinedAt: !449)
!680 = !DILocation(line: 183, column: 46, scope: !351, inlinedAt: !449)
!681 = !DILocation(line: 182, column: 5, scope: !351, inlinedAt: !449)
!682 = !DILocation(line: 183, column: 16, scope: !351, inlinedAt: !449)
!683 = !DILocation(line: 183, column: 24, scope: !351, inlinedAt: !449)
!684 = !{!685, !453, i64 8}
!685 = !{!"bpf_fib_lookup", !454, i64 0, !454, i64 1, !469, i64 2, !469, i64 4, !454, i64 6, !453, i64 8, !454, i64 12, !454, i64 16, !454, i64 32, !469, i64 48, !469, i64 50, !454, i64 52, !454, i64 58}
!686 = !DILocation(line: 184, column: 23, scope: !351, inlinedAt: !449)
!687 = !{!685, !454, i64 0}
!688 = !DILocation(line: 185, column: 39, scope: !351, inlinedAt: !449)
!689 = !DILocation(line: 185, column: 16, scope: !351, inlinedAt: !449)
!690 = !DILocation(line: 185, column: 20, scope: !351, inlinedAt: !449)
!691 = !{!454, !454, i64 0}
!692 = !DILocation(line: 186, column: 16, scope: !351, inlinedAt: !449)
!693 = !DILocation(line: 186, column: 28, scope: !351, inlinedAt: !449)
!694 = !{!685, !454, i64 1}
!695 = !DILocation(line: 187, column: 16, scope: !351, inlinedAt: !449)
!696 = !DILocation(line: 187, column: 22, scope: !351, inlinedAt: !449)
!697 = !{!685, !469, i64 2}
!698 = !DILocation(line: 188, column: 16, scope: !351, inlinedAt: !449)
!699 = !DILocation(line: 188, column: 22, scope: !351, inlinedAt: !449)
!700 = !{!685, !469, i64 4}
!701 = !DILocation(line: 189, column: 26, scope: !351, inlinedAt: !449)
!702 = !DILocation(line: 189, column: 16, scope: !351, inlinedAt: !449)
!703 = !DILocation(line: 189, column: 24, scope: !351, inlinedAt: !449)
!704 = !DILocation(line: 190, column: 16, scope: !351, inlinedAt: !449)
!705 = !DILocation(line: 190, column: 25, scope: !351, inlinedAt: !449)
!706 = !DILocation(line: 191, column: 27, scope: !351, inlinedAt: !449)
!707 = !DILocation(line: 191, column: 16, scope: !351, inlinedAt: !449)
!708 = !DILocation(line: 191, column: 25, scope: !351, inlinedAt: !449)
!709 = !DILocation(line: 193, column: 29, scope: !351, inlinedAt: !449)
!710 = !DILocation(line: 193, column: 14, scope: !351, inlinedAt: !449)
!711 = !DILocation(line: 210, column: 12, scope: !712, inlinedAt: !449)
!712 = distinct !DILexicalBlock(scope: !351, file: !3, line: 210, column: 9)
!713 = !DILocation(line: 210, column: 9, scope: !351, inlinedAt: !449)
!714 = !DILocation(line: 219, column: 45, scope: !715, inlinedAt: !449)
!715 = distinct !DILexicalBlock(scope: !716, file: !3, line: 219, column: 13)
!716 = distinct !DILexicalBlock(scope: !712, file: !3, line: 210, column: 41)
!717 = !DILocation(line: 219, column: 14, scope: !715, inlinedAt: !449)
!718 = !DILocation(line: 219, column: 13, scope: !716, inlinedAt: !449)
!719 = !DILocation(line: 222, column: 9, scope: !716, inlinedAt: !449)
!720 = !DILocation(line: 223, column: 9, scope: !716, inlinedAt: !449)
!721 = !DILocation(line: 224, column: 21, scope: !716, inlinedAt: !449)
!722 = !DILocation(line: 224, column: 29, scope: !716, inlinedAt: !449)
!723 = !DILocation(line: 225, column: 55, scope: !716, inlinedAt: !449)
!724 = !DILocation(line: 225, column: 16, scope: !716, inlinedAt: !449)
!725 = !DILocation(line: 225, column: 9, scope: !716, inlinedAt: !449)
!726 = !DILocation(line: 234, column: 1, scope: !351, inlinedAt: !449)
!727 = !DILocation(line: 242, column: 5, scope: !337)
!728 = distinct !DISubprogram(name: "pass", scope: !3, file: !3, line: 246, type: !338, scopeLine: 247, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !729)
!729 = !{!730}
!730 = !DILocalVariable(name: "ctx", arg: 1, scope: !728, file: !3, line: 246, type: !269)
!731 = !DILocation(line: 0, scope: !728)
!732 = !DILocation(line: 248, column: 5, scope: !728)
!733 = distinct !DISubprogram(name: "siphash", scope: !734, file: !734, line: 70, type: !735, scopeLine: 72, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !739)
!734 = !DIFile(filename: "./siphash.h", directory: "/home/conor/Workspace/College/fyp/src/balancer-xdp")
!735 = !DISubroutineType(types: !736)
!736 = !{null, !737, !157, !76, !157, !157, !157}
!737 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !738, size: 64)
!738 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !77)
!739 = !{!740, !741, !742, !743, !744, !745, !746, !747, !748, !749, !750, !751, !752, !753, !755}
!740 = !DILocalVariable(name: "in", arg: 1, scope: !733, file: !734, line: 70, type: !737)
!741 = !DILocalVariable(name: "in_size", arg: 2, scope: !733, file: !734, line: 70, type: !157)
!742 = !DILocalVariable(name: "out", arg: 3, scope: !733, file: !734, line: 70, type: !76)
!743 = !DILocalVariable(name: "out_size", arg: 4, scope: !733, file: !734, line: 71, type: !157)
!744 = !DILocalVariable(name: "k0", arg: 5, scope: !733, file: !734, line: 71, type: !157)
!745 = !DILocalVariable(name: "k1", arg: 6, scope: !733, file: !734, line: 71, type: !157)
!746 = !DILocalVariable(name: "v0", scope: !733, file: !734, line: 73, type: !157)
!747 = !DILocalVariable(name: "v1", scope: !733, file: !734, line: 74, type: !157)
!748 = !DILocalVariable(name: "v2", scope: !733, file: !734, line: 75, type: !157)
!749 = !DILocalVariable(name: "v3", scope: !733, file: !734, line: 76, type: !157)
!750 = !DILocalVariable(name: "m", scope: !733, file: !734, line: 77, type: !157)
!751 = !DILocalVariable(name: "i", scope: !733, file: !734, line: 78, type: !59)
!752 = !DILocalVariable(name: "end", scope: !733, file: !734, line: 79, type: !737)
!753 = !DILocalVariable(name: "left", scope: !733, file: !734, line: 80, type: !754)
!754 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !59)
!755 = !DILocalVariable(name: "b", scope: !733, file: !734, line: 81, type: !157)
!756 = !DILocation(line: 0, scope: !733)
!757 = !DILocation(line: 79, column: 39, scope: !733)
!758 = !DILocation(line: 80, column: 22, scope: !733)
!759 = !DILocation(line: 81, column: 38, scope: !733)
!760 = !DILocation(line: 85, column: 15, scope: !761)
!761 = distinct !DILexicalBlock(scope: !762, file: !734, line: 85, column: 5)
!762 = distinct !DILexicalBlock(scope: !733, file: !734, line: 85, column: 5)
!763 = !DILocation(line: 85, column: 5, scope: !762)
!764 = !DILocation(line: 86, column: 13, scope: !765)
!765 = distinct !DILexicalBlock(scope: !761, file: !734, line: 85, column: 32)
!766 = !DILocation(line: 87, column: 12, scope: !765)
!767 = !DILocation(line: 91, column: 13, scope: !768)
!768 = distinct !DILexicalBlock(scope: !769, file: !734, line: 91, column: 13)
!769 = distinct !DILexicalBlock(scope: !770, file: !734, line: 90, column: 9)
!770 = distinct !DILexicalBlock(scope: !765, file: !734, line: 90, column: 9)
!771 = !DILocation(line: 93, column: 12, scope: !765)
!772 = !DILocation(line: 85, column: 26, scope: !761)
!773 = distinct !{!773, !763, !774, !775}
!774 = !DILocation(line: 94, column: 5, scope: !762)
!775 = !{!"llvm.loop.mustprogress"}
!776 = !DILocation(line: 75, column: 14, scope: !733)
!777 = !DILocation(line: 83, column: 12, scope: !778)
!778 = distinct !DILexicalBlock(scope: !733, file: !734, line: 82, column: 9)
!779 = !DILocation(line: 96, column: 5, scope: !733)
!780 = !DILocation(line: 98, column: 29, scope: !781)
!781 = distinct !DILexicalBlock(scope: !733, file: !734, line: 96, column: 19)
!782 = !DILocation(line: 98, column: 19, scope: !781)
!783 = !DILocation(line: 98, column: 36, scope: !781)
!784 = !DILocation(line: 98, column: 15, scope: !781)
!785 = !DILocation(line: 98, column: 13, scope: !781)
!786 = !DILocation(line: 100, column: 29, scope: !781)
!787 = !DILocation(line: 100, column: 19, scope: !781)
!788 = !DILocation(line: 100, column: 36, scope: !781)
!789 = !DILocation(line: 100, column: 15, scope: !781)
!790 = !DILocation(line: 100, column: 13, scope: !781)
!791 = !DILocation(line: 102, column: 29, scope: !781)
!792 = !DILocation(line: 102, column: 19, scope: !781)
!793 = !DILocation(line: 102, column: 36, scope: !781)
!794 = !DILocation(line: 102, column: 15, scope: !781)
!795 = !DILocation(line: 102, column: 13, scope: !781)
!796 = !DILocation(line: 104, column: 29, scope: !781)
!797 = !DILocation(line: 104, column: 19, scope: !781)
!798 = !DILocation(line: 104, column: 36, scope: !781)
!799 = !DILocation(line: 104, column: 15, scope: !781)
!800 = !DILocation(line: 104, column: 13, scope: !781)
!801 = !DILocation(line: 106, column: 29, scope: !781)
!802 = !DILocation(line: 106, column: 19, scope: !781)
!803 = !DILocation(line: 106, column: 36, scope: !781)
!804 = !DILocation(line: 106, column: 15, scope: !781)
!805 = !DILocation(line: 106, column: 13, scope: !781)
!806 = !DILocation(line: 108, column: 29, scope: !781)
!807 = !DILocation(line: 108, column: 19, scope: !781)
!808 = !DILocation(line: 108, column: 36, scope: !781)
!809 = !DILocation(line: 108, column: 15, scope: !781)
!810 = !DILocation(line: 108, column: 13, scope: !781)
!811 = !DILocation(line: 110, column: 29, scope: !781)
!812 = !DILocation(line: 110, column: 19, scope: !781)
!813 = !DILocation(line: 110, column: 15, scope: !781)
!814 = !DILocation(line: 111, column: 13, scope: !781)
!815 = !DILocation(line: 116, column: 8, scope: !733)
!816 = !DILocation(line: 120, column: 9, scope: !817)
!817 = distinct !DILexicalBlock(scope: !818, file: !734, line: 120, column: 9)
!818 = distinct !DILexicalBlock(scope: !819, file: !734, line: 119, column: 5)
!819 = distinct !DILexicalBlock(scope: !733, file: !734, line: 119, column: 5)
!820 = !DILocation(line: 122, column: 8, scope: !733)
!821 = !DILocation(line: 127, column: 12, scope: !822)
!822 = distinct !DILexicalBlock(scope: !733, file: !734, line: 124, column: 9)
!823 = !DILocation(line: 131, column: 9, scope: !824)
!824 = distinct !DILexicalBlock(scope: !825, file: !734, line: 131, column: 9)
!825 = distinct !DILexicalBlock(scope: !826, file: !734, line: 130, column: 5)
!826 = distinct !DILexicalBlock(scope: !733, file: !734, line: 130, column: 5)
!827 = !DILocation(line: 133, column: 12, scope: !733)
!828 = !DILocation(line: 133, column: 17, scope: !733)
!829 = !DILocation(line: 133, column: 22, scope: !733)
!830 = !DILocation(line: 134, column: 5, scope: !733)
!831 = !DILocation(line: 135, column: 1, scope: !733)
!832 = distinct !DISubprogram(name: "compute_ipv4_checksum", scope: !185, file: !185, line: 31, type: !833, scopeLine: 31, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !835)
!833 = !DISubroutineType(types: !834)
!834 = !{!164, !57}
!835 = !{!836, !837, !838}
!836 = !DILocalVariable(name: "iph", arg: 1, scope: !832, file: !185, line: 31, type: !57)
!837 = !DILocalVariable(name: "iph16", scope: !832, file: !185, line: 32, type: !163)
!838 = !DILocalVariable(name: "csum", scope: !832, file: !185, line: 36, type: !157)
!839 = !DILocation(line: 0, scope: !832)
!840 = !DILocation(line: 37, column: 13, scope: !832)
!841 = !{!469, !469, i64 0}
!842 = !DILocation(line: 38, column: 46, scope: !832)
!843 = !DILocation(line: 38, column: 57, scope: !832)
!844 = !DILocation(line: 38, column: 55, scope: !832)
!845 = !DILocation(line: 43, column: 36, scope: !832)
!846 = !DILocation(line: 43, column: 28, scope: !832)
!847 = !DILocation(line: 45, column: 12, scope: !832)
!848 = !DILocation(line: 45, column: 5, scope: !832)
