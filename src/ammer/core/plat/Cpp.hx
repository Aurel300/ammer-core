package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

@:structInit
class CppConfig extends BaseConfig {
  public var staticLink:Bool = true;
}

typedef CppLibraryConfig = LibraryConfig;

typedef CppTypeMarshal = BaseTypeMarshal;

class Cpp extends Base<
  CppConfig,
  CppLibraryConfig,
  CppTypeMarshal,
  CppLibrary,
  CppMarshal
> {
  public function new(config:CppConfig) {
    super("cpp-static", config);
    if (!config.staticLink) throw "todo";
  }

  public function finalise():BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.abi.extension();
      var exth = lib.config.abi.extensionHeader();
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.cpp_static.$exth'),
        WriteContent(lib.lbHeader.done())
      ));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.cpp_static.$ext'),
        WriteContent(lib.lb.done())
      ));
    }
    return new BuildProgram(ops);
  }
}

@:allow(ammer.core.plat.Cpp)
class CppLibrary extends BaseLibrary<
  CppLibrary,
  CppConfig,
  CppLibraryConfig,
  CppTypeMarshal,
  CppMarshal
> {
  var lbHeader = new LineBuf();
  var nativeTypes:Map<String, {
    tdef:TypeDefinition,
    fields:Map<String, Bool>,
  }> = new Map();
  var nativeTypesOther:Array<TypeDefinition> = [];
  var haxeRefCt:ComplexType = null;

  function pushNative(name:String, signature:ComplexType, pos:Position):Void {
    tdef.fields.push({
      pos: pos,
      name: name,
      meta: [{
        pos: pos,
        params: [macro $v{name}],
        name: ":native",
      }],
      kind: TypeUtils.ffunCt(signature, macro throw 0),
      access: [APrivate, AStatic],
    });
  }

  public function new(config:CppLibraryConfig) {
    super(config, new CppMarshal(this));

    var native = typeDefCreate();
    native.name = '${config.typeDefName}_NativeHaxeRef';
    native.isExtern = true;
    native.meta = [{
      pos: config.pos,
      params: [macro "_ammer_haxe_ref"],
      name: ":native",
    }];
    nativeTypesOther.push(native);
    haxeRefCt = TPath({
      params: [TPType(TPath({
        pack: config.typeDefPack,
        name: native.name,
      }))],
      pack: ["cpp"],
      name: "Pointer", // Star?
    });

    pushNative("_ammer_ref_create",   (macro : (Dynamic) -> $haxeRefCt), config.pos);
    pushNative("_ammer_ref_delete",   (macro : ($haxeRefCt) -> Void), config.pos);
    pushNative("_ammer_ref_getcount", (macro : ($haxeRefCt) -> Int), config.pos);
    pushNative("_ammer_ref_setcount", (macro : ($haxeRefCt, Int) -> Void), config.pos);
    pushNative("_ammer_ref_getvalue", (macro : ($haxeRefCt) -> Dynamic), config.pos);

    lbHeader.ail('
#pragma once
typedef struct { ::Dynamic value; int32_t refcount; } _ammer_haxe_ref;
_ammer_haxe_ref* _ammer_ref_create(::Dynamic value);
void _ammer_ref_delete(_ammer_haxe_ref* ref);
int32_t _ammer_ref_getcount(_ammer_haxe_ref* ref);
void _ammer_ref_setcount(_ammer_haxe_ref* ref, int32_t rc);
::Dynamic _ammer_ref_getvalue(_ammer_haxe_ref* ref);
');
    lb.ail('
_ammer_haxe_ref* _ammer_ref_create(::Dynamic value) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = value;
  ref->refcount = 0;
  ::hx::GCAddRoot((hx::Object**)&ref->value);
  return ref;
}
void _ammer_ref_delete(_ammer_haxe_ref* ref) {
  ::hx::GCRemoveRoot((hx::Object**)&ref->value);
  ref->value = nullptr;
  ${config.freeFunction}(ref);
}
int32_t _ammer_ref_getcount(_ammer_haxe_ref* ref) {
  return ref->refcount;
}
void _ammer_ref_setcount(_ammer_haxe_ref* ref, int32_t rc) {
  ref->refcount = rc;
}
::Dynamic _ammer_ref_getvalue(_ammer_haxe_ref* ref) {
  return ref->value;
} // TODO: get/set unnecessary, just read/write field directly on native?
');
  }

  override function finalise(platConfig:CppConfig):Void {
    var ext = config.abi.extension();
    var exth = config.abi.extensionHeader();
    var absLibPath = sys.FileSystem.absolutePath('${platConfig.buildPath}/${config.name}');
    var headerPath = '$absLibPath/lib.cpp_static.$exth';
    var codePath = '$absLibPath/lib.cpp_static.$ext';
    tdef.meta.push({
      pos: Context.currentPos(),
      params: [macro $v{"#include \"" + headerPath + "\""}],
      name: ":headerCode",
    });
    tdef.meta.push({
      pos: Context.currentPos(),
      params: [macro $v{"#include \"" + codePath + "\""}],
      name: ":cppFileCode",
    });
    for (nativeType in nativeTypes) {
      nativeType.tdef.meta.push({
        pos: config.pos,
        params: [macro $v{"#include \"" + headerPath + "\""}],
        name: ":headerCode",
      });
    }
    for (nativeType in nativeTypesOther) {
      nativeType.meta.push({
        pos: config.pos,
        params: [macro $v{"#include \"" + headerPath + "\""}],
        name: ":headerCode",
      });
    }
    var xml = new LineBuf()
      .ail('<files id="haxe">')
      .i()
        .lmap(config.includePaths, path -> '<compilerflag value="-I$path"/>')
      .d()
      .ail("</files>")
      //.ifi(!platConfig.staticLink)
        .ail('<target id="haxe">')
        .i()
          .lmap(config.libraryPaths, path -> '<libpath name="$path"/>')
          .lmap(config.linkNames, name -> '<lib name="-l$name" unless="windows" />')
          .lmap(config.linkNames, name -> '<lib name="$name" if="windows" />')
        .d()
        .ail("</target>")
      //.ifd()
      .done();
    tdef.meta.push({
      name: ":buildXml",
      params: [{expr: EConst(CString(xml)), pos: config.pos}],
      pos: config.pos
    });
    //tdef.meta.push({
    //  name: ":fileXml",
    //  params: [{expr: EConst(CString(xml)), pos: config.pos}],
    //  pos: config.pos
    //});
    super.finalise(platConfig);
  }

  override public function addInclude(include:SourceInclude):Void {
    super.addInclude(include);
    lbHeader.ail(include.toCode());
  }

  override public function addHeaderCode(code:String):Void {
    lbHeader.ail(code);
  }

  public function addNamedFunction(
    name:String,
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ai('${ret.l1Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_$idx', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i();
    baseAddNamedFunction(
      args,
      args.mapi((idx, arg) -> '_l1_arg_$idx'),
      ret,
      "_l1_return",
      code,
      lb,
      options
    );
    lb
        .ifi(ret.mangled != "v")
          .ail('return _l1_return;')
        .ifd()
      .d()
      .ail("}");
    lbHeader
      .ai('${ret.l1Type} ${name}(')
      .map(args, arg -> arg.l1Type, ", ")
      .a(args.length == 0 ? "void" : "")
      .al(");");
    tdef.fields.push({
      pos: options.pos,
      name: name,
      meta: [{
        pos: options.pos,
        params: [macro $v{name}],
        name: ":native",
      }],
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType, macro throw 0),
      access: [APublic, AStatic],
    });
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<CppTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    // TODO: ref/unref args?
    return new LineBuf()
      .ail("do {")
      .i()
        .ail('${clType.type.l2Type} _l2_fn;')
        .ail(clType.type.l3l2(fn, "_l2_fn"))
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l3l2(arg, '_l2_arg_$idx'))
        .ail("_ammer_haxe_ref* _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("::Dynamic _l1_fn;")
        .ail("_l1_fn = _l1_fn_ref->value;")
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai('_l1_output = (${clType.ret.l1Type})(_l1_fn(')
        .ife()
          .ai('(${clType.ret.l1Type})(_l1_fn(')
        .ifd()
        .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
        .al("));")
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail("::hx::NativeAttach _cpp_attach_gc;")
        .ifi(ret.mangled != "v")
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('return ${config.returnIdent};')
        .ife()
          .ail(code)
        .ifd()
      .d()
      .al("}");
    return name;
  }
}

@:allow(ammer.core.plat.Cpp)
class CppMarshal extends BaseMarshal<
  CppMarshal,
  CppConfig,
  CppLibraryConfig,
  CppLibrary,
  CppTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):CppTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      l1Type:    over != null && over.l1Type    != null ? over.l1Type    : base.l1Type,
      l2Type:    over != null && over.l2Type    != null ? over.l2Type    : base.l2Type,
      l3Type:    over != null && over.l3Type    != null ? over.l3Type    : base.l3Type,
      mangled:   over != null && over.mangled   != null ? over.mangled   : base.mangled,
      l1l2:      over != null && over.l1l2      != null ? over.l1l2      : base.l1l2,
      l2ref:     over != null && over.l2ref     != null ? over.l2ref     : base.l2ref,
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2unref:   over != null && over.l2unref   != null ? over.l2unref   : base.l2unref,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
    };
  }

  static final MARSHAL_VOID = BaseMarshal.baseVoid();
  public function void():CppTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = BaseMarshal.baseBool();
  public function bool():CppTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8  = baseExtend(BaseMarshal.baseUint8(),  {arrayType: (macro : cpp.UInt8) });
  static final MARSHAL_INT8   = baseExtend(BaseMarshal.baseInt8(),   {arrayType: (macro : cpp.Int8)  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {arrayType: (macro : cpp.UInt16)});
  static final MARSHAL_INT16  = baseExtend(BaseMarshal.baseInt16(),  {arrayType: (macro : cpp.Int16) });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {arrayType: (macro : cpp.UInt32)});
  static final MARSHAL_INT32  = baseExtend(BaseMarshal.baseInt32(),  {arrayType: (macro : cpp.Int32) });
  public function uint8():CppTypeMarshal return MARSHAL_UINT8;
  public function int8():CppTypeMarshal return MARSHAL_INT8;
  public function uint16():CppTypeMarshal return MARSHAL_UINT16;
  public function int16():CppTypeMarshal return MARSHAL_INT16;
  public function uint32():CppTypeMarshal return MARSHAL_UINT32;
  public function int32():CppTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {arrayType: (macro : cpp.UInt64)});
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(),  {arrayType: (macro : cpp.Int64) });
  public function uint64():CppTypeMarshal return MARSHAL_UINT64;
  public function int64():CppTypeMarshal return MARSHAL_INT64;

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {arrayType: (macro : cpp.Float32)});
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {arrayType: (macro : cpp.Float64)});
  public function float32():CppTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CppTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = BaseMarshal.baseString();
  public function string():CppTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : cpp.Pointer<cpp.UInt8>),
  });
  function bytesInternalType():CppTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  } {
    var pathBytesRef = baseBytesRef(
      (macro : cpp.Pointer<cpp.UInt8>), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        var _ret = haxe.io.Bytes.alloc(_size); // TODO: does this zero unnecessarily?
        $e{blit(
          macro _self, macro 0,
          macro cpp.Pointer.ofArray(_ret.getData()), macro 0,
          macro _size
        )};
        _ret;
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = $e{alloc(macro _bytes.length)};
        $e{blit(
          macro cpp.Pointer.ofArray(_bytes.getData()), macro 0,
          macro _ret, macro 0,
          macro _bytes.length
        )};
        _ret;
      },

      toHaxeRef: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        haxe.io.Bytes.ofData(_self.toUnmanagedArray(_size));
      },
      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr = cpp.Pointer.ofArray(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaqueInternal(name:String):MarshalOpaque<CppTypeMarshal> {
    var native = library.typeDefCreate();
    native.name = '${library.config.typeDefName}_Native_${Mangle.identifier(name)}';
    native.isExtern = true;
    native.meta = [{
      pos: library.config.pos,
      params: [macro $v{name}],
      name: ":native",
    }];
    library.nativeTypes[name] = {
      tdef: native,
      fields: new Map(),
    };
    var haxeType:ComplexType = TPath({
      params: [TPType(TPath({
        pack: library.config.typeDefPack,
        name: native.name,
      }))],
      pack: ["cpp"],
      name: "Pointer", // Star?
    });
    return {
      type: baseExtend(BaseMarshal.baseOpaquePtrInternal(name), {
        haxeType: haxeType,
      }),
      typeDeref: baseExtend(BaseMarshal.baseOpaqueDirectInternal(name), {
        haxeType: haxeType,
      }),
    };
  }

  function arrayPtrInternalType(element:CppTypeMarshal):CppTypeMarshal {
    var elType = element.arrayType != null ? element.arrayType : element.haxeType;
    return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
      haxeType: (macro : cpp.Pointer<$elType>),
    });
  }
  override function arrayPtrInternalOps(
    type:CppTypeMarshal,
    element:CppTypeMarshal,
    alloc:(size:Expr)->Expr
    // blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    vectorType:Null<ComplexType>,
    toHaxeCopy:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeCopy:Null<(array:Expr)->Expr>,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(array:Expr)->Expr>,
  } {
    var elType = element.arrayType;
    var vectorType = (macro : haxe.ds.Vector<$elType>);
    var vectorTypePath = TypeUtils.complexTypeToPath(vectorType);
    var pathArrayRef = baseArrayRef(
      element, vectorType,
      (macro : cpp.Pointer<$elType>), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      vectorType: vectorType,
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<$elType>);
        var _size = ($size : Int);
        haxe.ds.Vector.fromData(_self.toUnmanagedArray(_size)).copy();
      },
      fromHaxeCopy: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        var _data:cpp.Pointer<$elType> = cpp.Pointer.ofArray(_vector.toData());
        // TODO: use alloc and blit instead?
        var _ret:cpp.Star<$elType> = cpp.Native.malloc(_vector.length << $v{element.arrayBits});
        cpp.Native.memcpy(_ret, _data, _vector.length << $v{element.arrayBits});
        cpp.Pointer.fromStar(_ret);
      },
      toHaxeRef: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<$elType>);
        var _size = ($size : Int);
        haxe.ds.Vector.fromData(_self.toUnmanagedArray(_size));
      },
      fromHaxeRef: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        var _ptr = cpp.Pointer.ofArray(_vector.toData());
        (@:privateAccess new $pathArrayRef(_vector, _ptr, 0));
      },
    };
  }

  // test of direct getter/setter optimisation
  /*
  override function structPtrInternalFieldGetter(
    structName:String,
    type:CppTypeMarshal,
    field:BaseFieldRef<CppTypeMarshal>
  ):(self:Expr)->Expr {
    return (switch (field.type) {
      case MARSHAL_VOID
      | MARSHAL_BOOL
      | MARSHAL_UINT8
      | MARSHAL_INT8
      | MARSHAL_UINT16
      | MARSHAL_INT16
      | MARSHAL_UINT32
      | MARSHAL_INT32
      | MARSHAL_UINT64
      | MARSHAL_INT64
      | MARSHAL_FLOAT32
      | MARSHAL_FLOAT64:
        var fname = field.name;
        var haxeType = field.type.haxeType;
        /*
        if (!library.nativeTypes[structName].fields.exists(fname)) {
          library.nativeTypes[structName].tdef.fields.push({
            pos: library.config.pos,
            name: fname,
            kind: FVar(field.type.haxeType, null),
            access: [APublic],
          });
          library.nativeTypes[structName].fields[fname] = true;
        }
        (self) -> macro ((@:privateAccess $self.ref.$fname) : $haxeType);
        * /
        var syntax = '{0}.$fname';
        (self) -> macro ((untyped __cpp__($v{syntax}, $self.ref)) : $haxeType);
      case _: super.structPtrInternalFieldGetter(structName, type, field);
    });
  }

  override function structPtrInternalFieldSetter(
    structName:String,
    type:CppTypeMarshal,
    field:BaseFieldRef<CppTypeMarshal>
  ):(self:Expr, val:Expr)->Expr {
    return (switch (field.type) {
      case MARSHAL_VOID
      | MARSHAL_BOOL
      | MARSHAL_UINT8
      | MARSHAL_INT8
      | MARSHAL_UINT16
      | MARSHAL_INT16
      | MARSHAL_UINT32
      | MARSHAL_INT32
      | MARSHAL_UINT64
      | MARSHAL_INT64
      | MARSHAL_FLOAT32
      | MARSHAL_FLOAT64:
        var fname = field.name;
        var haxeType = field.type.haxeType;
        /*
        if (!library.nativeTypes[structName].fields.exists(fname)) {
          library.nativeTypes[structName].tdef.fields.push({
            pos: library.config.pos,
            name: fname,
            kind: FVar(field.type.haxeType, null),
            access: [APublic],
          });
          library.nativeTypes[structName].fields[fname] = true;
        }
        (self, val) -> macro (if (true) { $self.ref.$fname = ($val : $haxeType); } : Void);
        * /
        var syntax = '{0}.$fname = {1}';
        (self, val) -> macro ((untyped __cpp__($v{syntax}, $self.ref, ($val : $haxeType))) : Void);
      case _: super.structPtrInternalFieldSetter(structName, type, field);
    });
  }
  */

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<CppTypeMarshal> {
    var res = baseHaxePtrInternal(
      haxeType,
      library.haxeRefCt,
      macro null,
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getvalue")})(handle),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getcount")})(handle),
      rc -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_setcount")})(handle, $rc),
      value -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_create")})($value),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_delete")})(handle)
    );
    library.nativeTypesOther.push(res.tdef);
    return res.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):CppTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: library.haxeRefCt,
    arrayType: (macro : cpp.Star<cpp.Void>),
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST("void*"),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("_ammer_haxe_ref*"),
  });

  public function new(library:CppLibrary) {
    super(library);
  }
}

#end
