package ammer.core;

#if macro

import haxe.macro.Expr;

typedef FunctionOptions = {
  // position to use for the corresponding field definitions; default: config.pos
  ?pos:Position,

  // L3 return expression; default: config.returnIdent
  ?l3Return:String,

  ?comment:String,
};

#end
