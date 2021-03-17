package main

import (
	"fmt"
	"strconv"
)

// built-in functions
func print(a ...interface{}) {
	fmt.Print(a...)
}

func println(a ...interface{}) {
	fmt.Println(a...)
}

// conversion functions
func conv_i_to_s(i int) string {
	return strconv.Itoa(i)
}

// Generated code

func multi_print(name string) {
	i := 0
	upper := 5
	for i < upper {
		println(name)
		i = i + 1
	}
}
func main() {
	multi_print("hello world")
}
