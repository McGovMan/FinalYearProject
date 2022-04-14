; ModuleID = 'xdp_decapsulator.c'
source_filename = "xdp_decapsulator.c"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "bpf"

%struct.xdp_md = type { i32, i32, i32, i32, i32 }
%struct.ethhdr = type { [6 x i8], [6 x i8], i16 }

@source_mac = dso_local local_unnamed_addr global [6 x i8] c"\08\00'\07\B7\19", align 1
@__const.decapsulator.____fmt = private unnamed_addr constant [10 x i8] c"Dia Dhuit\00", align 1
@_license = dso_local global [4 x i8] c"GPL\00", section "license", align 1
@__const.process_packet.____fmt = private unnamed_addr constant [11 x i8] c"got to end\00", align 1
@llvm.compiler.used = appending global [2 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @_license, i32 0, i32 0), i8* bitcast (i32 (%struct.xdp_md*)* @decapsulator to i8*)], section "llvm.metadata"

; Function Attrs: nounwind
define dso_local i32 @decapsulator(%struct.xdp_md* %0) #0 section "xdp_decapsulator" {
  %2 = alloca %struct.ethhdr, align 1
  %3 = alloca [11 x i8], align 1
  %4 = alloca [10 x i8], align 1
  %5 = getelementptr inbounds [10 x i8], [10 x i8]* %4, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 10, i8* nonnull %5) #3
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(10) %5, i8* noundef nonnull align 1 dereferenceable(10) getelementptr inbounds ([10 x i8], [10 x i8]* @__const.decapsulator.____fmt, i64 0, i64 0), i64 10, i1 false)
  %6 = call i64 (i8*, i32, ...) inttoptr (i64 6 to i64 (i8*, i32, ...)*)(i8* nonnull %5, i32 10) #3
  call void @llvm.lifetime.end.p0i8(i64 10, i8* nonnull %5) #3
  %7 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 0
  %8 = load i32, i32* %7, align 4, !tbaa !3
  %9 = zext i32 %8 to i64
  %10 = inttoptr i64 %9 to i8*
  %11 = getelementptr inbounds %struct.xdp_md, %struct.xdp_md* %0, i64 0, i32 1
  %12 = load i32, i32* %11, align 4, !tbaa !8
  %13 = zext i32 %12 to i64
  %14 = inttoptr i64 %13 to i8*
  %15 = inttoptr i64 %9 to %struct.ethhdr*
  %16 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %15, i64 1
  %17 = getelementptr %struct.ethhdr, %struct.ethhdr* %16, i64 0, i32 0, i64 0
  %18 = icmp ugt i8* %17, %14
  %19 = inttoptr i64 %13 to %struct.ethhdr*
  %20 = icmp ugt %struct.ethhdr* %16, %19
  %21 = or i1 %20, %18
  %22 = getelementptr inbounds i8, i8* %10, i64 34
  %23 = icmp ugt i8* %22, %14
  %24 = select i1 %21, i1 true, i1 %23
  br i1 %24, label %62, label %25

25:                                               ; preds = %1
  %26 = getelementptr inbounds i8, i8* %10, i64 23
  %27 = load i8, i8* %26, align 1, !tbaa !9
  %28 = icmp eq i8 %27, 17
  br i1 %28, label %29, label %59

29:                                               ; preds = %25
  %30 = getelementptr inbounds i8, i8* %10, i64 42
  %31 = icmp ugt i8* %30, %14
  br i1 %31, label %62, label %32

32:                                               ; preds = %29
  %33 = getelementptr inbounds i8, i8* %10, i64 36
  %34 = bitcast i8* %33 to i16*
  %35 = load i16, i16* %34, align 2, !tbaa !12
  %36 = icmp eq i16 %35, -3555
  br i1 %36, label %37, label %62

37:                                               ; preds = %32
  %38 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %2, i64 0, i32 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 14, i8* nonnull %38)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(14) %38, i8* noundef nonnull align 1 dereferenceable(14) %10, i64 14, i1 false) #3
  %39 = call i64 inttoptr (i64 44 to i64 (%struct.xdp_md*, i32)*)(%struct.xdp_md* nonnull %0, i32 44) #3
  %40 = trunc i64 %39 to i32
  %41 = icmp eq i32 %40, -1
  br i1 %41, label %56, label %42

42:                                               ; preds = %37
  %43 = load i32, i32* %7, align 4, !tbaa !3
  %44 = zext i32 %43 to i64
  %45 = inttoptr i64 %44 to i8*
  %46 = load i32, i32* %11, align 4, !tbaa !8
  %47 = zext i32 %46 to i64
  %48 = inttoptr i64 %47 to i8*
  %49 = getelementptr inbounds i8, i8* %45, i64 14
  %50 = icmp ugt i8* %49, %48
  %51 = inttoptr i64 %44 to %struct.ethhdr*
  br i1 %50, label %56, label %52

52:                                               ; preds = %42
  %53 = bitcast i8* %49 to %struct.ethhdr*
  %54 = inttoptr i64 %47 to %struct.ethhdr*
  %55 = icmp ugt %struct.ethhdr* %53, %54
  br i1 %55, label %56, label %57

56:                                               ; preds = %52, %42, %37
  call void @llvm.lifetime.end.p0i8(i64 14, i8* nonnull %38)
  br label %62

57:                                               ; preds = %52
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(14) %45, i8* noundef nonnull align 1 dereferenceable(14) %38, i64 14, i1 false) #3
  %58 = getelementptr inbounds %struct.ethhdr, %struct.ethhdr* %51, i64 0, i32 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(6) %58, i8* noundef nonnull align 1 dereferenceable(6) getelementptr inbounds ([6 x i8], [6 x i8]* @source_mac, i64 0, i64 0), i64 6, i1 false) #3
  call void @llvm.lifetime.end.p0i8(i64 14, i8* nonnull %38)
  br label %59

59:                                               ; preds = %57, %25
  %60 = getelementptr inbounds [11 x i8], [11 x i8]* %3, i64 0, i64 0
  call void @llvm.lifetime.start.p0i8(i64 11, i8* nonnull %60) #3
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(11) %60, i8* noundef nonnull align 1 dereferenceable(11) getelementptr inbounds ([11 x i8], [11 x i8]* @__const.process_packet.____fmt, i64 0, i64 0), i64 11, i1 false) #3
  %61 = call i64 (i8*, i32, ...) inttoptr (i64 6 to i64 (i8*, i32, ...)*)(i8* nonnull %60, i32 11) #3
  call void @llvm.lifetime.end.p0i8(i64 11, i8* nonnull %60) #3
  br label %62

62:                                               ; preds = %1, %29, %32, %56, %59
  %63 = phi i32 [ 2, %59 ], [ -1, %1 ], [ -1, %29 ], [ 2, %32 ], [ 1, %56 ]
  ret i32 %63
}

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly mustprogress nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly mustprogress nofree nosync nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { argmemonly mustprogress nofree nosync nounwind willreturn }
attributes #2 = { argmemonly mustprogress nofree nounwind willreturn }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"Ubuntu clang version 13.0.0-2"}
!3 = !{!4, !5, i64 0}
!4 = !{!"xdp_md", !5, i64 0, !5, i64 4, !5, i64 8, !5, i64 12, !5, i64 16}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!4, !5, i64 4}
!9 = !{!10, !6, i64 9}
!10 = !{!"iphdr", !6, i64 0, !6, i64 0, !6, i64 1, !11, i64 2, !11, i64 4, !11, i64 6, !6, i64 8, !6, i64 9, !11, i64 10, !5, i64 12, !5, i64 16}
!11 = !{!"short", !6, i64 0}
!12 = !{!13, !11, i64 2}
!13 = !{!"udphdr", !11, i64 0, !11, i64 2, !11, i64 4, !11, i64 6}
