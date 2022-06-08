package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalArray<TTypeMarshal> = {
  type:TTypeMarshal,

  get:(self:Expr, index:Expr)->Expr,
  set:(self:Expr, index:Expr, val:Expr)->Expr,

  alloc:(size:Expr)->Expr,
  zalloc:(size:Expr)->Expr,
  free:(self:Expr)->Expr,

  // TODO: offset? other functions from Bytes, zalloc, copy, blit

  vectorType:Null<ComplexType>,
  vectorTypePath:Null<TypePath>,

  toHaxeCopy:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeCopy:Null<(bytes:Expr)->Expr>,

  toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeRef:Null<(bytes:Expr)->Expr>,
};

#end
