package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

typedef NoneConfig = BaseConfig;

typedef NoneLibraryConfig = LibraryConfig;

typedef NoneTypeMarshal = BaseTypeMarshal;

class None extends Base<
  None,
  NoneConfig,
  NoneLibraryConfig,
  NoneTypeMarshal,
  NoneLibrary,
  NoneMarshal
> {
  public function new(config:NoneConfig) {
    super("none", config);
  }

  public function createLibrary(libConfig:NoneLibraryConfig):NoneLibrary {
    return new NoneLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return new BuildProgram([]);
  }
}

@:allow(ammer.core.plat)
class NoneLibrary extends BaseLibrary<
  NoneLibrary,
  None,
  NoneConfig,
  NoneLibraryConfig,
  NoneTypeMarshal,
  NoneMarshal
> {
  var lbHeader = new LineBuf();

  public function new(platform:None, config:NoneLibraryConfig) {
    super(platform, config, new NoneMarshal(this));
  }

  public function addNamedFunction(
    name:String,
    ret:NoneTypeMarshal,
    args:Array<NoneTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    return macro throw 0;
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<NoneTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    return "#invalid#";
  }

  public function addCallback(
    ret:NoneTypeMarshal,
    args:Array<NoneTypeMarshal>,
    code:String
  ):String {
    return "#invalid#";
  }
}

@:allow(ammer.core.plat)
class NoneMarshal extends BaseMarshal<
  NoneMarshal,
  None,
  NoneConfig,
  NoneLibraryConfig,
  NoneLibrary,
  NoneTypeMarshal
> {
  static final MARSHAL_VOID = BaseMarshal.baseVoid();
  public function void():NoneTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = BaseMarshal.baseBool();
  public function bool():NoneTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8  = BaseMarshal.baseUint8();
  static final MARSHAL_INT8   = BaseMarshal.baseInt8();
  static final MARSHAL_UINT16 = BaseMarshal.baseUint16();
  static final MARSHAL_INT16  = BaseMarshal.baseInt16();
  static final MARSHAL_UINT32 = BaseMarshal.baseUint32();
  static final MARSHAL_INT32  = BaseMarshal.baseInt32();
  public function uint8():NoneTypeMarshal return MARSHAL_UINT8;
  public function int8():NoneTypeMarshal return MARSHAL_INT8;
  public function uint16():NoneTypeMarshal return MARSHAL_UINT16;
  public function int16():NoneTypeMarshal return MARSHAL_INT16;
  public function uint32():NoneTypeMarshal return MARSHAL_UINT32;
  public function int32():NoneTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = BaseMarshal.baseUint64();
  static final MARSHAL_INT64  = BaseMarshal.baseInt64();
  public function uint64():NoneTypeMarshal return MARSHAL_UINT64;
  public function int64():NoneTypeMarshal return MARSHAL_INT64;

  static final MARSHAL_FLOAT32 = BaseMarshal.baseFloat32();
  static final MARSHAL_FLOAT64 = BaseMarshal.baseFloat64();
  public function float32():NoneTypeMarshal return MARSHAL_FLOAT32;
  public function float64():NoneTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = BaseMarshal.baseString();
  public function string():NoneTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = BaseMarshal.baseBytesInternal();
  function bytesInternalType():NoneTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  } {
    return {
      toHaxeCopy: (self, size) -> macro throw 0,
      fromHaxeCopy: (bytes) -> macro throw 0,

      toHaxeRef: (self, size) -> macro throw 0,
      fromHaxeRef: (bytes) -> macro throw 0,
    };
  }

  function opaqueInternal(name:String):NoneTypeMarshal {
    return BaseMarshal.baseOpaqueInternal(name);
  }

  function structPtrDerefInternal(name:String):NoneTypeMarshal {
    return BaseMarshal.baseStructPtrDerefInternal(name);
  }

  function arrayPtrInternalType(element:NoneTypeMarshal):NoneTypeMarshal {
    return BaseMarshal.baseArrayPtrInternal(element);
  }

  override function arrayPtrInternalOps(
    type:NoneTypeMarshal,
    element:NoneTypeMarshal,
    alloc:(size:Expr)->Expr
    // blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    vectorType:Null<ComplexType>,
    toHaxeCopy:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeCopy:Null<(array:Expr)->Expr>,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(array:Expr)->Expr>,
  } {
    return {
      vectorType: (macro : Void),
      toHaxeCopy: (self, size) -> macro throw 0,
      fromHaxeCopy: (vector) -> macro throw 0,
      toHaxeRef: (self, size) -> macro throw 0,
      fromHaxeRef: (vector) -> macro throw 0,
    };
  }

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<NoneTypeMarshal> {
    var res = baseHaxePtrInternal(
      haxeType,
      (macro : Int),
      macro null,
      macro throw 0,
      macro throw 0,
      rc -> macro throw 0,
      value -> macro throw 0,
      macro throw 0
    );
    TypeUtils.defineType(res.tdef);
    return res.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):NoneTypeMarshal return BaseMarshal.baseHaxePtrInternalType(haxeType);

  public function new(library:NoneLibrary) {
    super(library);
  }
}

#end
