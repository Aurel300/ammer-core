package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalArray<TTypeMarshal> = {
  type:TTypeMarshal,
  get:(self:Expr, index:Expr)->Expr,
  set:(self:Expr, index:Expr, val:Expr)->Expr,
  alloc:(size:Expr)->Expr,
  free:(self:Expr)->Expr,
};

#end
