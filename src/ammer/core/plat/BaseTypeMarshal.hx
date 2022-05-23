package ammer.core.plat;

#if macro

import haxe.macro.Expr;

typedef BaseTypeMarshal = {
  haxeType:ComplexType,
  l1Type:String,
  l2Type:String,
  l3Type:String,
  mangled:String,
  l1l2:(l1:String, l2:String)->String,
  l2ref:(l2:String)->String,
  l2l3:(l2:String, l3:String)->String,
  l3l2:(l3:String, l2:String)->String,
  l2unref:(l2:String)->String,
  l2l1:(l2:String, l1:String)->String,
};

#end
