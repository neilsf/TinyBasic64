module factor;

import pegged.grammar;
import program;
import expression;
import fun;
import std.array;
import std.conv;
import std.stdio;
import core.stdc.stdlib;

class Factor
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
    	string ftype = this.node.children[0].name;
        final switch(ftype) {
            case "TINYBASIC.Var":
                ParseTree v = this.node.children[0];
                string varname = join(v.children[0].matches);
                char vartype = this.program.type_conv(v.children[1].matches[0]);
                if(!this.program.is_variable(varname)) {
                    this.program.variables ~= Variable(0, varname, vartype);
                    this.program.error("Undefined variable: " ~ varname);
                }
                Variable var = this.program.findVariable(varname);
                this.asmcode ~= "\tp" ~ to!string(vartype) ~ "var " ~ var.getLabel() ~ "\n";
            break;

            case "TINYBASIC.Number":
                ParseTree v = this.node.children[0];
                string num_str = join(v.children[0].matches);
                int num = to!int(num_str);
                if(num < -32768 || num > 65535) {
                    this.program.error("Number out of range");
                }
                this.asmcode ~= "\tpword #" ~ num_str ~ "\n";
            break;

            case "TINYBASIC.Expression":
                ParseTree ex = this.node.children[0];
                auto Ex = new Expression(ex, this.program);
                Ex.eval();
                this.asmcode ~= to!string(Ex);
            break;

            case "TINYBASIC.Fn_call":
                ParseTree fn = this.node.children[0];
                auto fun = FunFactory(fn, this.program);
                fun.process();
                this.asmcode ~= to!string(fun);
            break;
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