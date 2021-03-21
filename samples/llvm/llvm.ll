; ModuleID = 'program'
source_filename = "program"

@0 = private unnamed_addr constant [15 x i8] c"Hellooo world!\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@2 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@3 = private unnamed_addr constant [1 x i8] zeroinitializer, align 1
@4 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1

declare i32 @puts(i8*)

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %x = alloca i32
  store i32 1, i32* %x
  %z = alloca i8*
  store i8* getelementptr inbounds ([15 x i8], [15 x i8]* @0, i32 0, i32 0), i8** %z
  %0 = load i32, i32* %x
  %1 = add i32 %0, 4
  %y = alloca i32
  store i32 %1, i32* %y
  %2 = load i8*, i8** %z
  %3 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @1, i32 0, i32 0), i8* %2)
  %4 = load i8*, i8** %z
  %5 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @2, i32 0, i32 0), i8* %4)
  %6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @4, i32 0, i32 0), i8* getelementptr inbounds ([1 x i8], [1 x i8]* @3, i32 0, i32 0))
  ret i32 0
}
