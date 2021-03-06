/*
 * ANTRL (http://www.antlr.org/) grammar for the project language. You will
 * probably want to adapt the file to generate parser for your language of
 * choice and use your own data structures (or define tree parser to traverse
 * the tree generated by ANTLR).
 *
 * Note that this has not been throughly tested, so let us know if there are
 * any problems.
 */

grammar TheLang;

options {
  language= Java;  /* Change this to generate parser for some other language. */
  backtrack = true;
  memoize = true;
  output = AST;
  ASTLabelType = CommonTree;
}

tokens {
  AND = '&';
  OR = '|';
  ASSIGN = ':=';
  SEMI = ';';
  GT = '>';
  GE = '>=';
  LT = '<';
  LE = '<=';
  EQ = '=';
  NEQ = '!=';
  PLUS = '+';
  MINUS = '-';
  MUL = '*';
  DIV = '/';
  NOT = '!';
  LPAREN = '(';
  RPAREN = ')';
  LBRACE = '{';
  RBRACE = '}';
  LBRACKET = '[';
  RBRACKET = ']';
  COLON = ':';
  IF = 'if';
  THEN = 'then';
  ELSE = 'else';
  FI = 'fi';
  WHILE = 'while';
  DO = 'do';
  OD = 'od';
  SKIP = 'skip';
  WRITE = 'write';
  READ = 'read';
  PROGRAM = 'program';
  END = 'end';
  TRUE = 'true';
  FALSE = 'false';
  INT = 'int';
  LOW = 'low';
  HIGH = 'high';
}


@header {
  package output;
  import syntaxtree.condition.*;
  import syntaxtree.declaration.*;
  import syntaxtree.expression.*;
  import syntaxtree.statement.*;
  import syntaxtree.*;
}
//aexpr : aexpr1 (PLUS aexpr1 | MINUS aexpr1)* ;
aexpr returns [Expression value]
    : arg1 = aexpr1 {$value = arg1.value;} 
      ( PLUS arg1 = aexpr1 {$value = new OperationExpression($value, arg1.value, ArithmeticOperation.PLUS); }
      | MINUS arg1 = aexpr1 {$value = new OperationExpression($value, arg1.value, ArithmeticOperation.MINUS);})*
    ;

//aexpr1 : aexpr2 (MUL aexpr2 | DIV aexpr2)* ;
aexpr1 returns [Expression value]
    : arg1 = aexpr2 {$value = arg1.value;} 
      ( MUL arg1 = aexpr2 {$value = new OperationExpression($value, arg1.value, ArithmeticOperation.MULTIPLICATION); } 
      | DIV arg1 = aexpr2 {$value = new OperationExpression($value, arg1.value, ArithmeticOperation.DIVISION);})*
    ;

//aexpr2 : MINUS aexpr3 | aexpr3;      
aexpr2 returns [Expression value]
    : MINUS expr = aexpr3 {$value = new NegationExpression(expr.value);}
    | expr = aexpr3 {$value = expr.value;}
    ;

//aexpr3 : IDENTIFIER (LBRACKET aexpr RBRACKET)? | INTEGER | LPAREN aexpr RPAREN;    
aexpr3 returns [Expression value] 
    : id = IDENTIFIER {$value = new Variable(Type.INT, id.getText());}
    | id = IDENTIFIER LBRACKET idx = aexpr RBRACKET {$value = new ArrayExpression(new Variable(Type.ARRAY, id.getText()), idx.value);}	
    | cons = INTEGER {$value = new Constant(Integer.parseInt($cons.getText()));}
    | LPAREN expr = aexpr RPAREN {$value = new ParanthesesExpression(expr.value);}
    ;

//bexpr : bexpr1 (OR bexpr1)*;
bexpr returns [Condition value]
    : expr = bexpr1 {$value = expr.value;} 
      (OR expr = bexpr1 {$value = new OperationCondition($value, expr.value, BooleanOperation.OR);})*
    ;

//bexpr1 : bexpr2 (AND bexpr2)*;
bexpr1 returns [Condition value]
    : expr = bexpr2 {$value = expr.value;} 
      (AND expr = bexpr2 {$value = new OperationCondition($value, expr.value, BooleanOperation.AND);})*
    ;

//bexpr2 : aexpr opr aexpr | NOT bexpr | TRUE | FALSE | LPAREN bexpr RPAREN;
bexpr2 returns [Condition value] 
    : expr1 = aexpr op = opr expr2 = aexpr {$value = new ExpressionOperationCondition(expr1.value, expr2.value, op.value);}
    | NOT cond = bexpr {$value = new NegationCondition(cond.value);} 
    | TRUE {$value = new TrueCondition();}
    | FALSE {$value = new FalseCondition();}
    | LPAREN cond = bexpr RPAREN {$value = new ParenthesesCondition(cond.value);} 
    ;

//opr : GT | GE | LT | LE | EQ | NEQ;
opr returns [RelationOperation value]
    : GT {$value = RelationOperation.GREATERTHAN;}
    | GE {$value = RelationOperation.GREATEREQUALTHAN;}
    | LT {$value = RelationOperation.LESSTHAN;}
    | LE {$value = RelationOperation.LESSEQUALTHAN;}
    | EQ {$value = RelationOperation.EQUAL;}
    | NEQ {$value = RelationOperation.NOTEQUAL;}
    ;

//decl : level? INT IDENTIFIER (LBRACKET INTEGER RBRACKET)? SEMI ;
decl returns [Declaration value]
    : lvl = level? INT id = IDENTIFIER SEMI {$value = new Int(lvl.value, new Variable(Type.INT, id.getText()));} 
    | lvl = level? INT id = IDENTIFIER LBRACKET size = INTEGER RBRACKET SEMI {$value = new Array(lvl.value, new Variable(Type.ARRAY, id.getText()), new Constant(Integer.parseInt(size.getText())));} 
    ;

//level : LOW | HIGH ;
level returns[Level value] 
    : LOW {$value = Level.LOW;}  
    | HIGH {$value = Level.HIGH;}
    | {$value = Level.UNKNOWN;}
    ;

//stmt : assignStmt | skipStmt | readStmt | writeStmt | ifStmt | whileStmt;  
stmt returns [Statement value]
     : statement1 = assignStmt {$value = statement1.value;}
     | statement2 = skipStmt {$value = statement2.value;}
     | statement3 = readStmt {$value = statement3.value;}
     | statement4 = writeStmt{$value = statement4.value;}
     | statement5 = ifStmt {$value = statement5.value;}
     | statement6 = whileStmt {$value = statement6.value;}
     ;

//assignStmt : IDENTIFIER (LBRACKET aexpr RBRACKET)? ASSIGN aexpr SEMI ;
assignStmt returns [Statement value]
    : id = IDENTIFIER ASSIGN expr = aexpr SEMI {$value = new Assignment(new Variable(Type.INT, id.getText()), expr.value);}
    | id = IDENTIFIER LBRACKET idx = aexpr RBRACKET ASSIGN expr = aexpr SEMI {$value = new ArrayAssignment(new Variable(Type.ARRAY, id.getText()), idx.value, expr.value);} 
    ;

//skipStmt : SKIP SEMI ;
skipStmt returns [Statement value]
    : SKIP SEMI {$value = new Skip();} 
    ;

//readStmt : READ IDENTIFIER (LBRACKET aexpr RBRACKET)? SEMI ;
readStmt returns [Statement value]
    : READ id = IDENTIFIER SEMI {$value = new Read(new Variable(Type.INT, id.getText()));}
    | READ id = IDENTIFIER LBRACKET idx = aexpr RBRACKET SEMI {$value = new ReadArray(new Variable(Type.INT, id.getText()), idx.value);}
    ;

//writeStmt : WRITE aexpr SEMI ;    
writeStmt returns [Statement value] 
    : WRITE expr = aexpr SEMI {$value = new Write(expr.value);} 
    ;

//ifStmt : IF bexpr THEN stmt+ ELSE stmt+ FI ;
ifStmt returns [Statement value]
    @init
    {
    	StatementList trueList = new StatementList();
	StatementList falseList = new StatementList();
    }
    : IF exp = bexpr THEN (trueStmt = stmt {trueList.add(trueStmt.value);})+ ELSE (falseStmt = stmt {falseList.add(falseStmt.value);})+ FI 
      {$value = new If(exp.value, trueList, falseList);}  
    ;
    
//whileStmt : WHILE bexpr DO stmt+ OD ;
whileStmt returns [Statement value]
    @init	
    {
    	StatementList body = new StatementList();
    }
    : WHILE exp = bexpr DO (statement = stmt {body.add(statement.value);})+ OD 
      {$value = new While(exp.value, body);} 
    ;

//program : PROGRAM decl* stmt+ END ;    
program returns [Program value]
    @init
    {
    	DeclarationList declList = new StatementList();
    	StatementList stmtList = new StatementList();
    }
    : PROGRAM (declaration = decl {declList.add($declaration.value);})* (statement = stmt {stmtList.add($statement.value);})+ END 
      {$value = new Program(declList, stmtList);} 
    ;

COMMENT : '(*' (options {greedy=false;} : .)* '*)' {$channel=HIDDEN;}
     ;

INTEGER : ('0' | '1'..'9' '0'..'9'*);

IDENTIFIER : LETTER (LETTER|'0'..'9')* ;

fragment
LETTER : 'A'..'Z'
       | 'a'..'z'
       | '_'
       ;

WS : (' '|'\r'|'\t'|'\u000C'|'\n') { skip(); } ;