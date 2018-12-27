module term;

import pegged.grammar;
import program;
import factor;
import std.conv;
import std.stdio;
import core.stdc.stdlib;

class Term
{
    ParseTree node;
    Program program;
    string asmcode;

    this(ParseTree node, Program program)
    { 
        this.node = node;
        this.program = program;
    }

    void eval()
    {
        char i = 0; 
    	Factor f1 = new Factor(this.node.children[i], this.program);
        f1.eval();
        this.asmcode ~= to!string(f1);
        if(this.node.children.length > 1) {
            for(i = 1; i < this.node.children.length; i += 2) {
                string t_op = this.node.children[i].matches[0];
                Factor f = new Factor(this.node.children[i+1], this.program);
                f.eval();
                this.asmcode ~= to!string(f);
                final switch(t_op) {
                    case "*":
                        this.asmcode ~= "\tmulw\n";
                    break;

                    case "/":
                        this.asmcode ~= "\tdivw\n";
                    break;
                }
            }
        }
    }
   
    void _type_error()
    {
        
    }

    override string toString()
    {
        return this.asmcode;
    }
}
