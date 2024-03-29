package ammer.core;

#if macro

import haxe.macro.Expr;

typedef MarshalClosure<TTypeMarshal> = {
  type:TTypeMarshal,
  create:(val:Expr)->Expr,
  restore:(handle:Expr)->Expr,
  ret:TTypeMarshal,
  args:Array<TTypeMarshal>,
  // TODO: move call generator here?
};

#end
