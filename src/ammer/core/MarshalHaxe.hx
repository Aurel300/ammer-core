package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalHaxe<TTypeMarshal> = {
  type:TTypeMarshal,
  refCt:ComplexType,
  create:(val:Expr)->Expr,
  restore:(handle:Expr)->Expr,
};

#end
