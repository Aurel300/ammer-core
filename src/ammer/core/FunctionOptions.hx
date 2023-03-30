package ammer.core;

#if macro

import haxe.macro.Expr;

typedef FunctionOptions = {
  /**
  Position to use for the corresponding field definitions.
  Default: `config.pos`
  **/
  ?pos:Position,

  /**
  L3 return expression.
  Default: `config.returnIdent`
  **/
  ?l3Return:String,

  /**
  Comment to include in the generated function.
  **/
  ?comment:String,
};

#end
