package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalStruct<TTypeMarshal> = {
  type:TTypeMarshal,
  typeDeref:TTypeMarshal,
  fieldGet:Map<String, (self:Expr)->Expr>,
  fieldSet:Map<String, (self:Expr, val:Expr)->Expr>,
  fieldRef:Map<String, (self:Expr)->Expr>,
  alloc:Null<Expr>,
  free:Null<(self:Expr)->Expr>,
  nullPtr:Null<Expr>,
};

#end
