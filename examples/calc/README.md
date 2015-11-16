# Calc

Calc is a very simple language capable of performing basic arithmetics.

It supports most of the operations you would expect to find on a basic (not
scientific) calculator.

## Examples

This is an example of a valid calc program (`# ...` are comments, blank lines
are ignored):

```
          # R = 0; M = 0

1 + 1     # R = 2; M = 0
+ 50 %    # R = 3; M = 0 (See http://blogs.msdn.com/b/oldnewthing/archive/2008/01/10/7047497.aspx)
M+        # R = 3; M = 3

1 + 2 * 3 # R = 7; M = 3 (Multiplication has higher precedence!)
M+        # R = 7; M = 10

15        # R = 15; M = 10
M-        # R = 15; M = -5
M-        # R = 15; M = -20

MR        # R = -20; M = -20
```

The result of this calc *Program* is `-20`. You can try inputing the same key
sequence into your OS's built-in calculator application (or a physical one) and
get the same result (hit the `=` key in between each line).

## Specification

While you can intuitively understand the Calc language as "how those cheap
calculators work", here is a more formal specification of the language.

### The Calc Machine

Calc *Program*s are executed on a *Calc Machine*. This abstract machine has two
registers, `R` (the *Result Register*) and `M` (the *Memory Register*). If you
are not familiar with the concept of a register, you can think of them as named
variables, "slots" or "cells" (as in spreadsheets) for holding a single number
each.

Both of these registers are initialized with the value `0`. As the *Program*
executes, it may modify the values stored in these two registers. When the
*Program* finishes execution successfully, the value on the `R` will be the
result of the program.

#### Error State

It is possible for the *Calc Machine* to enter the *Error State* due to illegal
operations (such as dividing a number by zero) or violating other constraints
imposed by the implementation (such as overflow/underflow).

When the *Calc Machine* enters the error state, all further operations have no
effect (i.e. there is no mechanism for "recovering" from an error).

A program that finished execution with the machine in the *Error State* has no
"result" (or you may say the result is an error).

### Grammar

This section describes the grammar of the language.

For simplicity, comments, whitespaces (except the newline character) and blank
lines are excluded from the grammar. You can imagine a preprocessing step that
removes them from a program before execution.

Formally, here is what it looks like:

```
<Program> ::= <Statements> | EMPTY

<Statements> ::= <Statement> | <Statement> "\n" <Statements>

<Statement> ::= <Command> | <Expression>

<Command> ::= "MR" | "MC" | "M+" | "M-"

<Expression> ::= <Continuation Expression> | <Simple Expression>

<Continuation Expression> ::= "+" <Simple Expression>
                            | "-" <Simple Expression>
                            | "*" <Simple Expression>
                            | "/" <Simple Expression>
                            | "%"

<Simple Expression> ::= <Simple Expression> "+" <Simple Expression>
                      | <Simple Expression> "-" <Simple Expression>
                      | <Simple Expression> "*" <Simple Expression>
                      | <Simple Expression> "/" <Simple Expression>
                      | <Value>

<Value> ::= <Number> | <Number> "%"

<Number> ::= <Digits> | <Digits> "." <Digits> | "." <Digits>

<Digits> ::= <Digit> | <Digit> <Digits>

<Digit> ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
```


