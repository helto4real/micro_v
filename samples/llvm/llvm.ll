; ModuleID = 'program'
source_filename = "program"

@0 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@1 = private unnamed_addr constant [3 x i8] c"%s\00", align 1
@2 = private unnamed_addr constant [12 x i8] c"hello again\00", align 1

declare i32 @puts(i8*)

declare i32 @printf(i8*, ...)

define i32 @main() {
entry:
  %i = alloca i32
  store i32 5, i32* %i
  br label %Label_2

Label_2:                                          ; preds = %Continue_1, %entry
  %0 = load i32, i32* %i
  %1 = icmp eq i32 %0, 0
  br i1 %1, label %Then_4, label %End_5

Then_4:                                           ; preds = %Label_2
  br label %Break_3
  br label %End_5

End_5:                                            ; preds = %Then_4, %Label_2
  %2 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i32 0, i32 0), i8* getelementptr inbounds ([12 x i8], [12 x i8]* @2, i32 0, i32 0))
  %3 = load i32, i32* %i
  %4 = sub i32 %3, 1
  store i32 %4, i32* %i
  br label %Continue_1

Continue_1:                                       ; preds = %End_5
  br label %Label_2

Break_3:                                          ; preds = %Then_4
  ret i32 0
}
