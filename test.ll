; ModuleID = 'main'
source_filename = "main"

define i32 @main() {
entry:
  %0 = alloca i32
  store i32 10, i32* %0
  %1 = alloca i32
  store i32 3, i32* %1
  %2 = load i32, i32* %0
  %3 = load i32, i32* %1
  %4 = mul i32 %2, %3
  ret i32 %4
}
