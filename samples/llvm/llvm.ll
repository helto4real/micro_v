; ModuleID = 'program'
source_filename = "program"

@0 = private unnamed_addr constant [40 x i8] c"Tomas is \C3\B6 the greatest of them all <3\00", align 1

declare i32 @puts(i8*)

define i32 @main() {
entry:
  %x = alloca i32
  store i32 1, i32* %x
  %z = alloca i8*
  store i8* getelementptr inbounds ([40 x i8], [40 x i8]* @0, i32 0, i32 0), i8** %z
  %0 = load i32, i32* %x
  %1 = add i32 %0, 4
  %y = alloca i32
  store i32 %1, i32* %y
  %2 = load i8*, i8** %z
  %3 = call i32 @puts(i8* %2)
  ret i32 0
}
