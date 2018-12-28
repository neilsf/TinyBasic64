module statements;

import pegged.grammar;
import program;
import std.string, std.conv, std.stdio;
import expression;
import stringliteral;

Stmt StmtFactory(ParseTree node, Program program) {
    string stmt_class =node.children[0].name;
    Stmt stmt;
    switch (stmt_class) {
        case "TINYBASIC.Let_stmt":
            stmt = new Let_stmt(node, program);
        break;

        case "TINYBASIC.Print_stmt":
            stmt = new Print_stmt(node, program);
        break;

        case "TINYBASIC.Goto_stmt":
            stmt = new Goto_stmt(node, program);
        break;

        case "TINYBASIC.Gosub_stmt":
            stmt = new Gosub_stmt(node, program);
        break;

        case "TINYBASIC.Return_stmt":
            stmt = new Return_stmt(node, program);
        break;

        case "TINYBASIC.End_stmt":
            stmt = new End_stmt(node, program);
        break;

        case "TINYBASIC.Rem_stmt":
            stmt = new Rem_stmt(node, program);
        break;

        case "TINYBASIC.If_stmt":
            stmt = new If_stmt(node, program);
        break;

        case "TINYBASIC.Poke_stmt":
            stmt = new Poke_stmt(node, program);
        break;

         case "TINYBASIC.Input_stmt":
            stmt = new Input_stmt(node, program);
        break;

        default:
        assert(0);
    }

    return stmt;
}

template StmtConstructor()
{
    this(ParseTree node, Program program)
    {
        super(node, program);
    }
}

interface StmtInterface
{
    void process();
}

abstract class Stmt:StmtInterface
{
    protected ParseTree node;
    protected Program program;

    this(ParseTree node, Program program)
    {
        this.node = node;
        this.program = program;
    }
}

class Let_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        ParseTree v = this.node.children[0].children[0];
        ParseTree ex = this.node.children[0].children[1];
        string varname = join(v.children[0].matches);
        char vartype = this.program.type_conv(v.children[1].matches[0]);
        if(!this.program.is_variable(varname)) {
            this.program.variables ~= Variable(0, varname, vartype);
        }
        Variable var = this.program.findVariable(varname);
        auto Ex = new Expression(ex, this.program);
        Ex.eval();
        this.program.program_segment ~= to!string(Ex);
        this.program.program_segment ~= "\tpl" ~ to!string(vartype) ~ "2var " ~ var.getLabel() ~ "\n";
    }
}

class Print_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        ParseTree exlist = this.node.children[0].children[0];
        for(char i=0; i< exlist.children.length; i++) {
            final switch(exlist.children[i].name) {
                case "TINYBASIC.Expression":
                    auto Ex = new Expression(exlist.children[i], this.program);
                    Ex.eval();
                    this.program.program_segment ~= to!string(Ex);
                    this.program.program_segment ~= "\tstdlib_printw\n";
                break;

                case "TINYBASIC.String":
                    string str = join(exlist.children[i].matches[1..$-1]);
                    Stringliteral sl = new Stringliteral(str, this.program);
                    sl.register();
                    this.program.program_segment ~= "\tlda #<_S" ~ to!string(Stringliteral.id) ~ "\n";
                    this.program.program_segment ~= "\tpha\n";
                    this.program.program_segment ~= "\tlda #>_S" ~ to!string(Stringliteral.id) ~ "\n";
                    this.program.program_segment ~= "\tpha\n";
                    this.program.program_segment ~= "\tstdlib_putstr\n";
                break;
            }
            
        }
    }
}

class Goto_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string lbl = join(this.node.children[0].children[0].matches);
        if(!this.program.labelExists(lbl)) {
            this.program.error("Label "~lbl~" does not exist");
        }

        this.program.program_segment ~= "\tjmp _L"~lbl~"\n";
        
    }
}

class Gosub_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        string lbl = join(this.node.children[0].children[0].matches);
        if(!this.program.labelExists(lbl)) {
            this.program.error("Label "~lbl~" does not exist");
        }

        this.program.program_segment ~= "\tjsr _L"~lbl~"\n";
        
    }
}

class Return_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        this.program.program_segment ~= "\trts\n";
    }
}

class End_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        this.program.program_segment ~= "\thalt\n";
    }
}

class Rem_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        {}
    }
}

class If_stmt:Stmt
{
    mixin StmtConstructor;

    public static ushort counter = 1;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        string rel = join(this.node.children[0].children[1].matches);
        auto e2 = this.node.children[0].children[2];
        auto st = this.node.children[0].children[3];

        auto Ex1 = new Expression(e1, this.program);
        Ex1.eval();
        auto Ex2 = new Expression(e2, this.program);
        Ex2.eval();

        this.program.program_segment ~= to!string(Ex1);
        this.program.program_segment ~= to!string(Ex2);

        string rel_type;

        final switch(rel) {
            case "<":
                rel_type = "lt";        
                break;
					
			case "<=":
                rel_type = "lte";    
				break;
					
			case "<>":
                rel_type = "neq";    
				break;
					
			case ">":
                rel_type = "gt";                    
				break;
					
			case ">=":
                rel_type = "gte";
				break;

            case "=":
                rel_type = "eq";
				break;
        }

        this.program.program_segment~="\tcmpw"~rel_type~"\n";
        string ret;
        ret ~= "\tpla\n"
             ~ "\tbne *+5\n"
             ~ "\tjmp _J" ~ to!string(counter)  ~ "\n";

        this.program.program_segment~=ret;

        Stmt stmt = StmtFactory(st, this.program);
        stmt.process();
            
        this.program.program_segment ~= "_J" ~to!string(counter)~ ":\n";
        counter++;
    }
}

class Poke_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        auto e1 = this.node.children[0].children[0];
        auto e2 = this.node.children[0].children[1];

        auto Ex1 = new Expression(e1, this.program);
        Ex1.eval();
        auto Ex2 = new Expression(e2, this.program);
        Ex2.eval();

        this.program.program_segment ~= to!string(Ex2); // value first
        this.program.program_segment ~= to!string(Ex1); // address last

        this.program.program_segment~="\tpoke\n";
    }
}

class Input_stmt:Stmt
{
    mixin StmtConstructor;

    void process()
    {
        ParseTree list = this.node.children[0].children[0];
        for(char i=0; i< list.children.length; i++) {
            ParseTree v = list.children[i];
            string varname = join(v.children[0].matches);
            char vartype = this.program.type_conv(v.children[1].matches[0]);
            if(!this.program.is_variable(varname)) {
                this.program.variables ~= Variable(0, varname, vartype);
            }
            Variable var = this.program.findVariable(varname);
        
            this.program.program_segment~="\tinput\n";
            this.program.program_segment~="\tplw2var " ~ var.getLabel() ~ "\n";
        }
    }
}