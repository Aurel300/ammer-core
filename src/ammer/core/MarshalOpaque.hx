package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalOpaque<TTypeMarshal> = {
  type:TTypeMarshal,
  typeDeref:TTypeMarshal,
};

#end
