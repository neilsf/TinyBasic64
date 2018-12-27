module tbgrammar;

import pegged.grammar;

mixin(grammar(`
TINYBASIC:
    Program <- Line (NL* Line)+ EOI
    Line <- Line_id :WS? Statement?

    Statement < Let_stmt / Print_stmt / If_stmt / Goto_stmt / Input_stmt / Gosub_stmt / Return_stmt / End_stmt / Rem_stmt / Poke_stmt
    Let_stmt <      "let" :WS? Var :WS? "=" :WS? Expression
    Print_stmt <    "print" :WS? ExprList
    If_stmt <       "if" :WS? Expression :WS? Relop :WS? Expression :WS? "then" :WS? Statement
    Goto_stmt <     "goto" :WS? (Label_ref / Unsigned)
    Input_stmt <    "input" :WS? VarList
    Gosub_stmt <    "gosub" :WS? (Label_ref / Unsigned)
    Return_stmt <   "return"
    Poke_stmt <     "poke" :WS? Expression :WS? "," :WS? Expression
    End_stmt <      "end"
    Rem_stmt <      "rem" (!eol .)*

    ExprList < (String / Expression) :WS? ("," :WS? (String / Expression) )*
    VarList < Var (:WS? "," :WS? Var)*
    Expression < ("+" / "-" / eps) :WS? Term :WS? (E_OP :WS? Term)*
    Term < Factor :WS? (T_OP :WS? Factor)*
    Factor < (Var / Number / Expression / Fn_call)
    Fn_call < Id "(" :WS? ExprList :WS? ")"
    Var < Varname Vartype

    T_OP < ("*" / "/")
    E_OP < ("+" / "-")
    
    Varname <- !Reserved [a-zA-Z_] [a-zA-Z_0-9]*
    Id <- [a-zA-Z_] [a-zA-Z_0-9]*
    Vartype <- ("$" / "%" / "#" / "&" / eps)

    Relop < "<" | "<=" | "=" | "<>" | ">" | ">="
    String < doublequote (!doublequote . / ^' ')* doublequote

    Unsigned   < [0-9]+
    Integer    < "-"? Unsigned
    Hexa       < "$" [0-9a-fA-F]+    
    
    Number < (Integer / Hexa)

    Label < [a-zA-Z_] [a-zA-Z_0-9]* ":"
    Label_ref < [a-zA-Z_] [a-zA-Z_0-9]*

    Line_id < (Label / Unsigned / eps)

    Reserved < ("let" / "print" / "if" / "then" / "goto" / "input" / "gosub" / "return" / "end" / "rem" / "poke" / "peek")
    
    WS < space*
    EOI < !.

    NL <- ('\r' / '\n' / '\r\n')+
    Spacing <- :('\t')*  
`));
