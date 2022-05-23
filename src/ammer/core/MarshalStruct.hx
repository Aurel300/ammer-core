package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalStruct<TTypeMarshal> = {
  type:TTypeMarshal,
  getters:Map<String, (self:Expr)->Expr>,
  setters:Map<String, (self:Expr, val:Expr)->Expr>,
  alloc:Null<Expr>,
  free:Null<(self:Expr)->Expr>,
  nullPtr:Null<Expr>,
};

#end
