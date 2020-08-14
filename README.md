# Cal in RISC-V Assembler

This is a version of the long-standing `cal` program.  The only reason
it's interesting at all is that it's written in RISC-V 64-bit assembler.

It doesn't even do much:

       $ cal <month> <year>

where `<month>` is a number from 1-12, inclusive, and `<year>` is a number
assumed to be Current Era (CE).  It will then print out what that month
looks like in table form.

That's it.

## License
Everything in this project is licensed under GPL v2.0.

## The Makefile
The goal of this exercise was to learn RISC-V assembler and use it to
do something slightly more than trivial.  Please read the `Makefile`.

What you'll see is the default target builds `cal`; there is another
target called `examples` that builds bits of code and captures the GCC
generated assembly code -- clever stuff like the standard "Hello, world"
that was written in order to see how varargs are called.

Generally speaking, if a example creates something that can be run, there
will also be a target called `run-executable` to actually run the RISC-V
object code.  For example, there is an example called `hello` that also
has a target called `run-hello`.

## See Ya Later
Have fun.

Al Stone <ahs3@ahs3.net>

