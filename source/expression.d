module expression;

import pegged.grammar;
import program;
import term;
import std.conv;
import std.stdio;
import core.stdc.stdlib;

class Expression
{
    ParseTree node;
    Program program;
    bool negateFirstTerm;
    string asmcode;

    this(ParseTree node, Program program)
    { 
        this.node = node;
        this.program = program;
    }

    void eval()
    {
    	this.negateFirstTerm = (this.node.matches[0] == "-");
        char i = 0; 
    	Term t1 = new Term(this.node.children[i], this.program);
        t1.eval();
        this.asmcode ~= to!string(t1);
        if(this.negateFirstTerm) {
            this.asmcode ~= "\tnegw\n";
        }
        if(this.node.children.length > 1) {
            for(i = 1; i < this.node.children.length; i += 2) {
                string e_op = this.node.children[i].matches[0];
                Term t = new Term(this.node.children[i+1], this.program);
                t.eval();
                this.asmcode ~= to!string(t);
                final switch(e_op) {
                    case "+":
                        this.asmcode ~= "\taddw\n";
                    break;

                    case "-":
                        this.asmcode ~= "\tsubw\n";
                    break;
                }
            }
        }
    }
   
    void _type_error()
    {
        this.program.error("Only byte types can make part of a logical expression");
    }

    override string toString()
    {
        return this.asmcode;
    }
}

