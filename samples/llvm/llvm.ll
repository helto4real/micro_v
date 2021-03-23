; ModuleID = 'program'
source_filename = "program"

@0 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@2 = private unnamed_addr constant [6 x i8] c"tomas\00", align 1

declare i32 @puts(i8*)

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %i = alloca i32
  store i32 0, i32* %i
  %upper = alloca i32
  store i32 5, i32* %upper
  br label %Label_4

Body_2:                                           ; preds = %Label_4
  %0 = load i32, i32* %i
  %1 = icmp eq i32 %0, 2
  br i1 %1, label %Then_5, label %End_6

Then_5:                                           ; preds = %Body_2
  br label %Continue_1

End_6:                                            ; preds = %Body_2
  %2 = load i32, i32* %i
  %3 = icmp eq i32 %2, 4
  br i1 %3, label %Then_7, label %End_8

Then_7:                                           ; preds = %End_6
  br label %Break_3

End_8:                                            ; preds = %End_6
  %4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i32 0, i32 0), i8* getelementptr inbounds ([6 x i8], [6 x i8]* @2, i32 0, i32 0))
  br label %Continue_1

Continue_1:                                       ; preds = %End_8, %Then_5
  %5 = load i32, i32* %i
  %6 = add i32 %5, 1
  store i32 %6, i32* %i
  br label %Label_4

Label_4:                                          ; preds = %Continue_1, %entry
  %7 = load i32, i32* %i
  %8 = load i32, i32* %upper
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %Body_2, label %Break_3

Break_3:                                          ; preds = %Label_4, %Then_7
  ret i32 0
}
