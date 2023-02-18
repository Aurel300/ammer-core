package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalArray<TTypeMarshal> = {
  type:TTypeMarshal,

  get:(self:Expr, index:Expr)->Expr,
  set:(self:Expr, index:Expr, val:Expr)->Expr,
  ref:(self:Expr, index:Expr)->Expr,

  alloc:(size:Expr)->Expr,
  zalloc:(size:Expr)->Expr,
  free:(self:Expr)->Expr,
  nullPtr:Null<Expr>,

  // TODO: offset? other functions from Bytes, zalloc, copy, blit

  vectorType:Null<ComplexType>,
  vectorTypePath:Null<TypePath>,

  toHaxeCopy:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeCopy:Null<(vec:Expr)->Expr>,

  toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeRef:Null<(vec:Expr)->Expr>,
};

#end
