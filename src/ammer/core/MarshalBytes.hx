package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalBytes<TTypeMarshal> = {
  type:TTypeMarshal,

  get8:(self:Expr, index:Expr)->Expr,
  get16:(self:Expr, index:Expr)->Expr,
  get32:(self:Expr, index:Expr)->Expr,

  set8:(self:Expr, index:Expr, val:Expr)->Expr,
  set16:(self:Expr, index:Expr, val:Expr)->Expr,
  set32:(self:Expr, index:Expr, val:Expr)->Expr,

  // TODO: endian variants for 16/32

  alloc:(size:Expr)->Expr,
  zalloc:(size:Expr)->Expr,
  nullPtr:Expr,
  free:(self:Expr)->Expr,
  copy:(self:Expr, size:Expr)->Expr,
  blit:(source:Expr, sourcepos:Expr, dest:Expr, destpos:Expr, size:Expr)->Expr,

  // TODO: offset ...?

  toHaxeCopy:(self:Expr, size:Expr)->Expr,
  fromHaxeCopy:(bytes:Expr)->Expr,

  toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeRef:Null<(bytes:Expr)->Expr>,
};

#end
