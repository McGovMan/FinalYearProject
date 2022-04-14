; ModuleID = 'xdp_balancer_kern.c'
source_filename = "xdp_balancer_kern.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.xdp_md = type { i32, i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }

@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1
@llvm.compiler.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @balancer to i8*), i8* bitcast (i32 (%struct.xdp_md*)* @xdp_pass_func to i8*)], section "llvm.metadata"

; Function Attrs: mustprogress nofree nosync nounwind readonly willreturn
define dso_local i32 @balancer(%struct.xdp_md* nocapture readonly %0) #0 section "xdp_balancer" {
  %2 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0
  %3 = load i32, i32* %2, align 4, !tbaa !3
  %4 = zext i32 %3 to i64
  %5 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1
  %6 = load i32, i32* %5, align 4, !tbaa !8
  %7 = zext i32 %6 to i64
  %8 = inttoptr i64 %7 to i8*
  %9 = inttoptr i64 %4 to %struct.ethhdr*
  %10 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 1
  %11 = inttoptr i64 %7 to %struct.ethhdr*
  %12 = icmp ugt %struct.ethhdr* %10, %11
  br i1 %12, label %49, label %13

13:                                               ; preds = %1
  %14 = getelementptr %struct.ethhdr, %struct.ethhdr* %10, i64 0, i32 0, i64 0
  %15 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 0, i32 2
  %16 = load i16, i16* %15, align 1, !tbaa !9
  %17 = tail call i16 @llvm.bswap.i16(i16 %16) #3
  switch i16 %17, label %49 [
    i16 2054, label %18
    i16 2048, label %19
    i16 -31011, label %35
  ]

18:                                               ; preds = %13
  br label %49

19:                                               ; preds = %13
  %20 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 1, i32 0, i64 20
  %21 = icmp ugt i8* %20, %8
  br i1 %21, label %43, label %22

22:                                               ; preds = %19
  %23 = load i8, i8* %14, align 4
  %24 = shl i8 %23, 2
  %25 = and i8 %24, 60
  %26 = icmp ult i8 %25, 20
  br i1 %26, label %43, label %27

27:                                               ; preds = %22
  %28 = zext i8 %25 to i64
  %29 = getelementptr %struct.ethhdr, %struct.ethhdr* %9, i64 1, i32 0, i64 %28
  %30 = icmp ugt i8* %29, %8
  br i1 %30, label %43, label %31

31:                                               ; preds = %27
  %32 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 1, i32 0, i64 9
  %33 = load i8, i8* %32, align 1, !tbaa !12
  %34 = zext i8 %33 to i32
  br label %43

35:                                               ; preds = %13
  %36 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 3, i32 2
  %37 = inttoptr i64 %7 to i16*
  %38 = icmp ugt i16* %36, %37
  br i1 %38, label %43, label %39

39:                                               ; preds = %35
  %40 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %9, i64 1, i32 1, i64 0
  %41 = load i8, i8* %40, align 2, !tbaa !14
  %42 = zext i8 %41 to i32
  br label %43

43:                                               ; preds = %39, %35, %31, %27, %22, %19
  %44 = phi i32 [ %34, %31 ], [ -1, %19 ], [ -1, %22 ], [ -1, %27 ], [ %42, %39 ], [ -1, %35 ]
  %45 = icmp eq i32 %44, 6
  %46 = icmp eq i32 %44, 17
  %47 = or i1 %45, %46
  %48 = select i1 %47, i32 3, i32 1
  br label %49

49:                                               ; preds = %1, %13, %18, %43
  %50 = phi i32 [ 1, %13 ], [ 2, %18 ], [ %48, %43 ], [ 1, %1 ]
  ret i32 %50
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define dso_local i32 @xdp_pass_func(%struct.xdp_md* nocapture readnone %0) #1 section "xdp_pass" {
  ret i32 2
}

; Function Attrs: mustprogress nofree nosync nounwind readnone speculatable willreturn
declare i16 @llvm.bswap.i16(i16) #2

attributes #0 = { mustprogress nofree nosync nounwind readonly willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind readnone willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { mustprogress nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"clang version 13.0.0 (Red Hat 13.0.0-2.el9)"}
!3 = !{!4, !5, i64 0}
!4 = !{!"xdp_md", !5, i64 0, !5, i64 4, !5, i64 8, !5, i64 12, !5, i64 16, !5, i64 20}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!4, !5, i64 4}
!9 = !{!10, !11, i64 12}
!10 = !{!"ethhdr", !6, i64 0, !6, i64 6, !11, i64 12}
!11 = !{!"short", !6, i64 0}
!12 = !{!13, !6, i64 9}
!13 = !{!"iphdr", !6, i64 0, !6, i64 0, !6, i64 1, !11, i64 2, !11, i64 4, !11, i64 6, !6, i64 8, !6, i64 9, !11, i64 10, !5, i64 12, !5, i64 16}
!14 = !{!15, !6, i64 6}
!15 = !{!"ipv6hdr", !6, i64 0, !6, i64 0, !6, i64 1, !11, i64 4, !6, i64 6, !6, i64 7, !16, i64 8, !16, i64 24}
!16 = !{!"in6_addr", !6, i64 0}
