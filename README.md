# drakkar
Drakkar is LL(k) parser generator, but still a **WIP** (work in progress).

**Do not use it yet**

### Goals
The goal of Drakkar is to check if a grammar is indeed LL(k) and generate a human-readable (not table based) parser.

**As for today (end 2019)** :
* focus on LL(1) only !
* the intended target is Ruby code.
* drakkar only check if a grammar is LL(1).

      Drakkar LL(k) parser generator
      [+] analyzing expr.gram
       |->[+] parsing  grammar
       |->[+] checking grammar
           |->[+] uniqueness  ✔
           |->[+] check use/def  ✔
           |->[+] check LL(1)
               |->[+] rule 'expr' ✔
               |->[+] rule 'comp_op' ✔
               |->[+] rule 'additive' ✔
               |->[+] rule 'additive_op' ✔
               |->[+] rule 'multitive' ✔
               |->[+] rule 'multitive_op' ✔
               |->[+] rule 'term' ✔
               |->[+] rule 'ident' ✔
               |->[+] rule 'int_lit' ✔
      [+] result : your grammar is LL(1)

* if the grammar is not LL(1), Drakkar indicates which rules do not respect LL(1) principles, and provide the paths through the rules that are in errors.

      Drakkar LL(k) parser generator
      [+] analyzing assign_call.gram
       |->[+] parsing  grammar
       |->[+] checking grammar
           |->[+] uniqueness  ✔
           |->[+] check use/def  ✔
           |->[+] check LL(1)
               |->[+] rule 'stmt'
                   |->[+] not LL(1). starter '/[a-zA-Z]+/' reached 2 times ✗
                       |->[+] path assign->id->/[a-zA-Z]+/
                       |->[+] path call->id->/[a-zA-Z]+/
               |->[+] rule 'assign' ✔
               |->[+] rule 'call' ✔
               |->[+] rule 'id' ✔
      [+] result : your grammar is NOT LL(1)

### Grammar syntax


The Grammar of the grammars understood by Drakkar looks like the following. Note that tokens can be expressed through quotes like _'!='_ or directly via (Ruby) regular expressions. Notice also that each rule ends with a semi-colon ;

      grammar Expr

        expr          ::= additive (comp_op additive)*            ;
        comp_op       ::= '==' | '!=' | '>' | '>=' | '<' | '<='   ;

        additive      ::= multitive (additive_op multitive)*    ;
        additive_op   ::= '+' | '-' |'or'                       ;

        multitive     ::= term (multitive_op term)*             ;
        multitive_op  ::= '*' | '/' | '%' | '&' | '>>' | '<<'   ;

        term          ::= ident | int_lit ;

        ident         ::= /[a-z]*/ ;
        int_lit       ::= /\d+/    ;
      end
