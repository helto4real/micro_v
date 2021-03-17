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