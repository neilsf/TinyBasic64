import std.stdio, std.array, std.conv, std.string, std.file, std.path;
import pegged.grammar;
import core.stdc.stdlib;
import statements;

struct Variable {
    ushort location;
    string name;
    char type;

    string getLabel()
    {
        return "_" ~ this.name;
    }
}

class Program
{
    struct ProgramSettings {
        ushort heap_start;
        ushort heap_end;
        ushort program_start;
        ushort program_end;
    }

    ProgramSettings settings;

    ubyte[char] varlen;
    char[ubyte] vartype;

    Variable[] variables;
    Variable[] external_variables;
    Variable[] program_data;

    string[] labels;

    //Procedure[] procedures;

    ushort stringlit_counter = 0;
    string program_segment;
    string data_segment;

    char last_type;

    ParseTree current_node;

    this() {
        /* As of now, vartypes with the same length are not allowed. Needs refactoring if it is a must */
        this.varlen['b'] = 1; this.vartype[1] = 'b';
        this.varlen['w'] = 2; this.vartype[2] = 'w';
        this.varlen['s'] = 2; this.vartype[2] = 's';
        //this.varlen['i'] = 3; this.vartype[3] = 'i';
        //this.varlen['f'] = 5; this.vartype[5] = 'f';
        this.settings = ProgramSettings(0xc000, 0xcfff, 0x0801, 0x9999);
    }

    bool labelExists(string str)
    {
        foreach(ref e; this.labels) {
            if(e == str) {
                return true;
            }
        }

        return false;
    }

    void addLabel(string str) 
    {
        if(this.labelExists(str)) {
            this.error("Label "~str~" already defined");
        }

        this.labels ~= str;
    }

    char type_conv(string type)
    {
        if(type == "" || type == "#") {
            return 'w';
        }
        else if(type == "$") {
            return 's';
        } 
        else {
            return 'b';
        }
    }
    
    string getDataSegment()
    {
    	string ret = "data_start:\n";
    	ret ~= this.data_segment ~ "data_end:\n";
    	return ret;
    }
    
    string getVarSegment()
    {
    	string varsegment;

        varsegment ~= "\t;--------------\n";
        varsegment ~= "\tSEG.U variables\n";
        varsegment ~= "\tORG data_end+1\n";

    	foreach(ref variable; this.variables) {
    		ubyte varlen = this.varlen[variable.type];
    		varsegment ~= variable.getLabel() ~"\tDS.B " ~ to!string(varlen) ~ "\n";
    	}

    	return varsegment;  
    }

    string getCodeSegment()
    {
        string codesegment;
        codesegment ~= "prg_start:\n";
        codesegment ~= "\tinit_program\n";
        codesegment ~= this.program_segment;
        codesegment ~= "prg_end:\n";
        codesegment ~= "\trts\n";
        return codesegment;
    }

    string getAsmCode()
    {
        string asm_code;

        asm_code ~= "\tPROCESSOR 6502\n\n";
        asm_code ~= "\tSEG UPSTART\n";
	    asm_code ~= "\tORG $0801\n";
	    asm_code ~= "\tDC.W next_line\n";
	    asm_code ~= "\tDC.W 2018\n";
	    asm_code ~= "\tHEX 9e\n";
	    asm_code ~= "\tIF prg_start\n";
	    asm_code ~= "\tDC.B [prg_start]d\n";
	    asm_code ~= "\tENDIF\n";
	    asm_code ~= "\tHEX 00\n";
        asm_code ~= "next_line:\n\tHEX 00 00\n";
        asm_code ~= "\t;--------------------\n";
        asm_code ~= "\tINCDIR \"" ~ std.path.dirName(std.file.thisExePath()) ~ "/lib\"\n";
        asm_code ~= "\tINCLUDE \"nucleus.asm\"\n";
        asm_code ~= "\tINCLUDE \"stdlib.asm\"\n";

        asm_code ~= this.getCodeSegment();
        asm_code ~= this.getDataSegment();
        asm_code ~= this.getVarSegment();

        return asm_code;
    }

    ubyte[3] intToBin(int number)
    {
    	ubyte[3] data_bytes;
    
			if(number < 0) {
					number = 16777216 + number;
				}
			
			try {
				data_bytes[0] = to!ubyte(number >> 16);
				data_bytes[1] = to!ubyte((number & 65280) >> 8);
				data_bytes[2] = to!ubyte(number & 255);
			}
			catch(Exception e) {
				this.error("Compile error: number out of range: "~to!string(number));
			}
			
			return data_bytes;
    }

    float parseFloat(string strval)
    {
	    return to!float(strval);
    }

    int parseInt(string strval)
    {
	  try {
		  if(strval[0] == '$') {
				  return to!int(strval[1..$] ,16);
			  }
			  else if(strval[0] == '%') {
				  return to!int(strval[1..$] ,2);
			  }
			  else {
				  return to!int(strval);
			  }
	  } catch (std.conv.ConvException e) {
		  this.error("Syntax error: '" ~ strval ~"' is not a valid integer literal");
	  }

	  return 0;
    }

    void assertIdExists(string id)
    {
    	if(idExists(id)) {
    		this.error("Semantic error: can't redefine '" ~ id ~"'");
    	}
    }

    Variable findVariable(string id)
    {
        foreach(ref elem; this.variables) {
    		if(id == elem.name) {
    			return elem;
    		}
    	}

        assert(0);
    }

    bool is_variable(string id)
    {
        foreach(ref elem; this.variables) {
    		if(id == elem.name) {
    			return true;
    		}
    	}

        return false;
    }

    bool idExists(string id)
    {
    	return (this.is_variable(id));
    }

    char guessTheType(string number)
    {
        if(number.indexOfAny(".") > -1) {
            return 'f';
        }
        int numericval = this.parseInt(number);
        if(numericval < 0 ||  numericval > 65535) {
            return 'i';
        }
        else if(numericval > 255) {
            return 'w';
        }
        else {
            return 'b';
        }
    }

    void error(string error_message)
    {
        ulong error_location = to!uint(this.current_node.begin);
        string partial = this.current_node.input[0..error_location];
        auto lines = splitLines(partial);
        ulong line_no = lines.length + 1;
        writeln("ERROR: " ~ error_message ~ " in line " ~ to!string(lines.length));
        exit(1);
    }

    void warning(string msg)
    {
        writeln("WARNING: "~msg);
    }

    void processLine(ParseTree node)
    {
        //writeln(node);
        auto Line_id = node.children[0];
        string label_type = Line_id.children.length == 0 ? "TINYBASIC.none" : Line_id.children[0].name;
        switch(label_type) {
            case "TINYBASIC.Unsigned":
            string line_no = join(Line_id.children[0].matches);
            this.program_segment ~= "_L" ~ line_no ~ ":\n";
            break;

            case "TINYBASIC.Label":
            string label = join(Line_id.children[0].matches[0..$-1]);
            this.program_segment ~= "_L" ~ label ~ ":\n";
            break;

            default:
            break;
        }

        // line has statement?
        if(node.children.length > 1) {
            Stmt stmt = StmtFactory(node.children[1], this);
            stmt.process();
        }
    }

    void fetchLabels(ParseTree node)
    {
        
        foreach(ref child; node.children[0].children) {

            // empty row?
            if(child.name != "TINYBASIC.Line" || child.children.length == 0) {
                continue;
            }
            
            auto Line_id = child.children[0];
            string label_type = Line_id.children.length == 0 ? "TINYBASIC.none" : Line_id.children[0].name;
            switch(label_type) {
                case "TINYBASIC.Unsigned":
                string line_no = join(Line_id.children[0].matches);
                this.addLabel(line_no);
                break;

                case "TINYBASIC.Label":
                string label = join(Line_id.children[0].matches[0..$-1]);
                this.addLabel(label);
                break;

                default:
                break;
            }
        }
    }

    void processAst(ParseTree node)
    {
        fetchLabels(node);

        ubyte level = 1;
        void walkAst(ParseTree node)
        {
            this.current_node = node;

            level +=1;
            
            switch(node.name) {

                    case "TINYBASIC.Line":
                        this.processLine(node);
                        break;

                    default:
                        foreach(ref child; node.children) {
                            walkAst(child);
                        }
                    break;

            }

            level -=1;
        }

        walkAst(node);
    }
}
