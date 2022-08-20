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
  l2l3:(l2:String, l3:String)->String,
  l3l2:(l3:String, l2:String)->String,
  l2l1:(l2:String, l1:String)->String,

  // If present, this type can be used as an element in direct array methods
  // (e.g. toHaxeRef). In that case, `arrayBits` is the bitshift needed to get
  // from an array size to the backing byte buffer size (same as sizeBits).
  // `arrayType` is the type used as the type argument for `haxe.ds.Vector`.
  ?arrayBits:Int, // TODO: rename to primitiveSize ? in bytes
  ?arrayType:ComplexType,
};

typedef BaseTypeMarshalOpt = {
  ?haxeType:ComplexType,
  ?l1Type:String,
  ?l2Type:String,
  ?l3Type:String,
  ?mangled:String,
  ?l1l2:(l1:String, l2:String)->String,
  ?l2l3:(l2:String, l3:String)->String,
  ?l3l2:(l3:String, l2:String)->String,
  ?l2l1:(l2:String, l1:String)->String,

  ?arrayBits:Int,
  ?arrayType:ComplexType,
};

#end
