package ammer.core;

#if macro

import haxe.macro.Expr;

class Marshal {
  var kind:PlatformId;
  var marshal:Dynamic;

  function new(kind:PlatformId, marshal:Dynamic) {
    this.kind = kind;
    this.marshal = marshal;
  }

  // TODO: options
  public function fieldRef(name:String, type:TypeMarshal):FieldRef {
    return (switch (kind) {
      case Cpp: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Cpp.CppTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Cpp.CppTypeMarshal>);
      case Cs: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Cs.CsTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Cs.CsTypeMarshal>);
      case Hashlink: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Hashlink.HashlinkTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Hashlink.HashlinkTypeMarshal>);
      case Java: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Java.JavaTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Java.JavaTypeMarshal>);
      case Lua: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Lua.LuaTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Lua.LuaTypeMarshal>);
      case Neko: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Neko.NekoTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Neko.NekoTypeMarshal>);
      case Nodejs: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Nodejs.NodejsTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Nodejs.NodejsTypeMarshal>);
      case Python: cast ({
          name: name,
          type: (cast type : ammer.core.plat.Python.PythonTypeMarshal),
        } : ammer.core.plat.BaseFieldRef<ammer.core.plat.Python.PythonTypeMarshal>);
    });
  }

  public function void():TypeMarshal return marshal.void();
  public function bool():TypeMarshal return marshal.bool();
  public function uint8():TypeMarshal return marshal.uint8();
  public function uint16():TypeMarshal return marshal.uint16();
  public function uint32():TypeMarshal return marshal.uint32();
  public function uint64():TypeMarshal return marshal.uint64();
  public function int8():TypeMarshal return marshal.int8();
  public function int16():TypeMarshal return marshal.int16();
  public function int32():TypeMarshal return marshal.int32();
  public function int64():TypeMarshal return marshal.int64();
  public function float32():TypeMarshal return marshal.float32();
  public function float64():TypeMarshal return marshal.float64();
  public function bytes():MarshalBytes<TypeMarshal> return marshal.bytes();
  public function string():TypeMarshal return marshal.string();
  public function opaque(name:String):MarshalOpaque<TypeMarshal> return marshal.opaque(name);
  public function boxPtr(type:TypeMarshal):MarshalBox<TypeMarshal> return marshal.boxPtr(type);
  public function structPtr(name:String, fields:Array<FieldRef>, allocatable:Bool = true):MarshalStruct<TypeMarshal>
    return marshal.structPtr(name, fields, allocatable);
  public function arrayPtr(element:TypeMarshal):MarshalArray<TypeMarshal>
    return marshal.arrayPtr(element);
  public function haxePtr(haxeType:ComplexType):MarshalHaxe<TypeMarshal>
    return marshal.haxePtr(haxeType);
  public function closure(ret:TypeMarshal, args:Array<TypeMarshal>):MarshalClosure<TypeMarshal>
    return marshal.closure(ret, args);
}

#end
