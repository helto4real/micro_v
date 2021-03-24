; ModuleID = 'program'
source_filename = "program"

@0 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"world\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@3 = private unnamed_addr constant [6 x i8] c"world\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@5 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@6 = private unnamed_addr constant [2 x i8] c" \00", align 1

declare i32 @puts(i8*)

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %0 = alloca i8*
  br i1 true, label %1, label %2

1:                                                ; preds = %entry
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @0, i32 0, i32 0), i8** %0
  br label %5

2:                                                ; preds = %entry
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @1, i32 0, i32 0), i8** %0
  br label %5

3:                                                ; preds = %5
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i32 0, i32 0), i8** %7
  br label %8

4:                                                ; preds = %5
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @3, i32 0, i32 0), i8** %7
  br label %8

5:                                                ; preds = %2, %1
  %6 = load i8*, i8** %0
  %x = alloca i8*
  store i8* %6, i8** %x
  %7 = alloca i8*
  br i1 false, label %3, label %4

8:                                                ; preds = %4, %3
  %9 = load i8*, i8** %7
  %y = alloca i8*
  store i8* %9, i8** %y
  %10 = load i8*, i8** %x
  %11 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @5, i32 0, i32 0), i8* %10)
  %12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @5, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @6, i32 0, i32 0))
  %13 = load i8*, i8** %y
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @4, i32 0, i32 0), i8* %13)
  ret i32 0
}
