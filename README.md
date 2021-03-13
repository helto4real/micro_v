# The micro V - minimal v language compiler
This is a learning project to build a compiler for the awesome V langues

# Overall design
The compiler works like this:
## 1. Tokenizer
The source text is tokenized into tokens that are parsed by the parser. 

## 2. Parser
The parser parses all tokens into an AST (abstract syntax tree). 

## 3. Binding
Analyses the the AST, binds the symbols and types, does the semantic checks etc.

A part of the binding process is different levels of "lowering", take the AST node and make lower version. As an example: a for loop is turned inot labels and gotos. Depending on back-end different levels of lowering is needed.

The binding also manage the scope and levels of scope. The GlobalScope is a special scope that has information of all top-level statements, constants and function declarations. 

## 4. Compiler
Handles the compiling process that starts with tokenizing and ends ether with evaluation/intepretation or a code generation to selected back-end

## 5. Evaluation
Inteprets the lowered bound AST. 

## 6. Code generation
If not in intepreter scriptmode it will generate code depending on selected back-end. (Not decided yet the default one. Considering LLVM, C or MIL)

# Modules
## lib module
Lib module contiains all built-in libraries in micro V. 

## lib.comp
this module contains all logic that relates to the compiler/intepreter. 

## lib.com.ast
All the nodes in the abstract syntax tree. 