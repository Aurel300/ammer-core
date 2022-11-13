package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalBytes<TTypeMarshal> = {
  type:TTypeMarshal,

  get8:(self:Expr, index:Expr)->Expr,
  get16:(self:Expr, index:Expr)->Expr,
  get32:(self:Expr, index:Expr)->Expr,
  get64:(self:Expr, index:Expr)->Expr,

  set8:(self:Expr, index:Expr, val:Expr)->Expr,
  set16:(self:Expr, index:Expr, val:Expr)->Expr,
  set32:(self:Expr, index:Expr, val:Expr)->Expr,
  set64:(self:Expr, index:Expr, val:Expr)->Expr,

  get16be:(self:Expr, index:Expr)->Expr,
  get32be:(self:Expr, index:Expr)->Expr,
  get64be:(self:Expr, index:Expr)->Expr,
  set16be:(self:Expr, index:Expr, val:Expr)->Expr,
  set32be:(self:Expr, index:Expr, val:Expr)->Expr,
  set64be:(self:Expr, index:Expr, val:Expr)->Expr,

  get16le:(self:Expr, index:Expr)->Expr,
  get32le:(self:Expr, index:Expr)->Expr,
  get64le:(self:Expr, index:Expr)->Expr,
  set16le:(self:Expr, index:Expr, val:Expr)->Expr,
  set32le:(self:Expr, index:Expr, val:Expr)->Expr,
  set64le:(self:Expr, index:Expr, val:Expr)->Expr,

  alloc:(size:Expr)->Expr,
  zalloc:(size:Expr)->Expr,
  nullPtr:Expr,
  free:(self:Expr)->Expr,
  copy:(self:Expr, size:Expr)->Expr,
  blit:(source:Expr, sourcepos:Expr, dest:Expr, destpos:Expr, size:Expr)->Expr,
  offset:(self:Expr, pos:Expr)->Expr,
  // TODO: fill?

  toHaxeCopy:(self:Expr, size:Expr)->Expr,
  fromHaxeCopy:(bytes:Expr)->Expr,

  toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
  fromHaxeRef:Null<(bytes:Expr)->Expr>,
};

#end
