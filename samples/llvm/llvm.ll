; ModuleID = 'program'
source_filename = "program"

%JumpBuffer = type { i64 }

@jmp_buf = global %JumpBuffer zeroinitializer
@sprintf_buff = global [21 x i8] zeroinitializer
@0 = private unnamed_addr constant [7 x i8] c"helloo\00", align 1
@1 = private unnamed_addr constant [6 x i8] c"world\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"hello\00", align 1
@3 = private unnamed_addr constant [6 x i8] c"world\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@5 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@6 = private unnamed_addr constant [2 x i8] c" \00", align 1

declare void @longjmp(%JumpBuffer*, i64)

declare i64 @setjmp(%JumpBuffer*)

declare i32 @printf(i8*, ...)

declare void @exit(i32)

declare i32 @sprintf(i8*, i8*, ...)

define i32 @main() {
entry:
  %0 = call i64 @setjmp(%JumpBuffer* @jmp_buf)
  %1 = icmp eq i64 %0, 0
  br i1 %1, label %continue, label %error_exit

2:                                                ; preds = %continue
  store i8* getelementptr inbounds ([7 x i8], [7 x i8]* @0, i32 0, i32 0), i8** %6
  br label %7

3:                                                ; preds = %continue
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @1, i32 0, i32 0), i8** %6
  br label %7

4:                                                ; preds = %7
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i32 0, i32 0), i8** %9
  br label %10

5:                                                ; preds = %7
  store i8* getelementptr inbounds ([6 x i8], [6 x i8]* @3, i32 0, i32 0), i8** %9
  br label %10

continue:                                         ; preds = %entry
  %6 = alloca i8*
  br i1 true, label %2, label %3

error_exit:                                       ; preds = %entry
  ret i32 1

7:                                                ; preds = %3, %2
  %8 = load i8*, i8** %6
  %x = alloca i8*
  store i8* %8, i8** %x
  %9 = alloca i8*
  br i1 false, label %4, label %5

10:                                               ; preds = %5, %4
  %11 = load i8*, i8** %9
  %y = alloca i8*
  store i8* %11, i8** %y
  %12 = load i8*, i8** %x
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @5, i32 0, i32 0), i8* %12)
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @5, i32 0, i32 0), i8* getelementptr inbounds ([2 x i8], [2 x i8]* @6, i32 0, i32 0))
  %15 = load i8*, i8** %y
  %16 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @4, i32 0, i32 0), i8* %15)
  ret i32 0
}
