# TinyBasic64
A Tiny BASIC cross-compiler for the Commodore-64 

This program will compile Tiny BASIC source code to Commodore-64 assembly in DASM format.

## Disclaimer
This project is still in beta. Please report any bugs that you may have found and I'll fix them as soon as possible.

## Usage
1. Pick a pre-built executable from the `bin/` dir and copy it to the project dir or type `dub build` to compile from source (install dub first).
2. In the project dir type `./tinybasic64 source.bas > target.asm` to compile basic source code to assembly source.

## Differences in syntax
There are a few differences to the original gramamar definition ([read Tiny BASIC on Wikipedia](https://en.wikipedia.org/wiki/Tiny_BASIC)):
1. Keywords are in lowercase.
2. Line numbers are optional. You can use labels, line numbers or both. The following example will compile:
```
10 rem this line is numbered
20 gosub my_sub
print "this is just a line"
end
my_sub:
  print "this will be printed first"
  return
```
3. Variable names are case-sensitive and they can consist of any letters, numbers or underscores of any length. (they must not start with a number though).
4. `gosub <expression>` and `goto <expression>` are not supported. You can only use labels or line numbers.
5. `poke n,m` and `peek(n)` are supported
