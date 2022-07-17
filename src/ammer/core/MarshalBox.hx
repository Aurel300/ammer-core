package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalBox<TTypeMarshal> = {
  type:TTypeMarshal,
  get:(self:Expr)->Expr,
  set:(self:Expr, val:Expr)->Expr,
  alloc:Null<Expr>,
  free:Null<(self:Expr)->Expr>,
  nullPtr:Null<Expr>,
};

#end
