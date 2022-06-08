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
  free:(self:Expr)->Expr,
  copy:(self:Expr, size:Expr)->Expr,
  blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr,

  // TODO: offset ...?

  // TODO: rename with Haxe instead of Bytes

  toBytesCopy:(self:Expr, size:Expr)->Expr,
  fromBytesCopy:(bytes:Expr)->Expr,

  toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
  fromBytesRef:Null<(bytes:Expr)->Expr>,
};

#end
