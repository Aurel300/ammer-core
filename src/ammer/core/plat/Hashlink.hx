package ammer.core.plat;

#if macro

@:structInit
class HashlinkConfig extends BaseConfig {
  public var hlc:Bool = false;
  public var hlIncludePaths:Array<String> = null;
  public var hlLibraryPaths:Array<String> = null;
}

typedef HashlinkLibraryConfig = LibraryConfig;

typedef HashlinkTypeMarshalExt = {
  hlType:String,
};
typedef HashlinkTypeMarshal = {
  >BaseTypeMarshal,
  >HashlinkTypeMarshalExt,
};

class Hashlink extends Base<
  Hashlink,
  HashlinkConfig,
  HashlinkLibraryConfig,
  HashlinkTypeMarshal,
  HashlinkLibrary,
  HashlinkMarshal
> {
  public function new(config:HashlinkConfig) {
    super("hl", config);
  }

  public function createLibrary(libConfig:HashlinkLibraryConfig):HashlinkLibrary {
    return new HashlinkLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.hlIncludePaths,
      libraryPaths: config.hlLibraryPaths,
      linkNames: [BuildProgram.useMSVC ? "libhl" : "hl"],
    });
  }
}

@:allow(ammer.core.plat)
class HashlinkLibrary extends BaseLibrary<
  HashlinkLibrary,
  Hashlink,
  HashlinkConfig,
  HashlinkLibraryConfig,
  HashlinkTypeMarshal,
  HashlinkMarshal
> {
  var staticCallbackIds:Array<String> = [];

  function pushNative(name:String, signature:ComplexType, pos:Position):Void {
    tdef.fields.push({
      pos: pos,
      name: name,
      meta: [{
        pos: pos,
        params: [
          macro $v{config.name},
          macro $v{name},
        ],
        name: ":hlNative",
      }],
      kind: TypeUtils.ffunCt(signature, macro throw 0),
      access: [APrivate, AStatic],
    });
  }

  public function new(platform:Hashlink, config:HashlinkLibraryConfig) {
    super(platform, config, new HashlinkMarshal(this));

    #if (haxe >= version("4.2.6") && hl_ver >= version("1.12.0") && !hl_legacy32)
    pushNative("_ammer_init",         (macro : (String, hl.NativeArray<Any>) -> Void), config.pos);
    #else
    pushNative("_ammer_init",         (macro : (haxe.Int64, String, hl.NativeArray<Any>) -> Void), config.pos);
    #end
    pushNative("_ammer_ref_create",   (macro : (Dynamic) -> hl.Abstract<"abstract_haxe_ref">), config.pos);
    pushNative("_ammer_ref_delete",   (macro : (hl.Abstract<"abstract_haxe_ref">) -> Void), config.pos);
    pushNative("_ammer_ref_getcount", (macro : (hl.Abstract<"abstract_haxe_ref">) -> Int), config.pos);
    pushNative("_ammer_ref_setcount", (macro : (hl.Abstract<"abstract_haxe_ref">, Int) -> Void), config.pos);
    pushNative("_ammer_ref_getvalue", (macro : (hl.Abstract<"abstract_haxe_ref">) -> Dynamic), config.pos);

    // TODO: prefix
    lb.ail('
#define HL_NAME(n) ${config.name}_ ## n
#include "hl.h"

typedef struct { void* value; int32_t refcount; } _ammer_haxe_ref;
HL_PRIM _ammer_haxe_ref* HL_NAME(_ammer_ref_create)(vdynamic* value) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = value;
  ref->refcount = 0;
  hl_add_root(&ref->value);
  return ref;
}
DEFINE_PRIM(_ABSTRACT(abstract_haxe_ref), _ammer_ref_create, _DYN);
HL_PRIM void HL_NAME(_ammer_ref_delete)(_ammer_haxe_ref* ref) {
  hl_remove_root(&ref->value);
  ref->value = NULL;
  ${config.freeFunction}(ref);
}
DEFINE_PRIM(_VOID, _ammer_ref_delete, _ABSTRACT(abstract_haxe_ref));
HL_PRIM int32_t HL_NAME(_ammer_ref_getcount)(_ammer_haxe_ref* ref) {
  return ref->refcount;
}
DEFINE_PRIM(_I32, _ammer_ref_getcount, _ABSTRACT(abstract_haxe_ref));
HL_PRIM void HL_NAME(_ammer_ref_setcount)(_ammer_haxe_ref* ref, int32_t rc) {
  ref->refcount = rc;
}
DEFINE_PRIM(_VOID, _ammer_ref_setcount, _ABSTRACT(abstract_haxe_ref) _I32);
HL_PRIM vdynamic* HL_NAME(_ammer_ref_getvalue)(_ammer_haxe_ref* ref) {
  return (vdynamic*)ref->value;
}
DEFINE_PRIM(_DYN, _ammer_ref_getvalue, _ABSTRACT(abstract_haxe_ref));

static varray* _ammer_haxe_scb;
typedef struct { hl_type* t; vbyte* data; int32_t len; } _ammer_haxe_string;
static hl_type* _ammer_haxe_string_type;
');
    #if (haxe >= version("4.2.6") && hl_ver >= version("1.12.0") && !hl_legacy32)
    lb.ail('HL_PRIM void HL_NAME(_ammer_init)(_ammer_haxe_string* ex_string, varray* scb) {
  _ammer_haxe_string_type = ex_string->t;
  _ammer_haxe_scb = scb;
  hl_add_root(&_ammer_haxe_scb);
}
DEFINE_PRIM(_VOID, _ammer_init, _OBJ(_BYTES _I32) _ARR);');
    #else
    lb.ail('
typedef struct { hl_type *t; int32_t high; int32_t low; } _ammer_haxe_int64;
static hl_type *_ammer_haxe_int64_type;
HL_PRIM void HL_NAME(_ammer_init)(_ammer_haxe_int64* ex_int64, _ammer_haxe_string* ex_string, varray* scb) {
  _ammer_haxe_int64_type = ex_int64->t;
  _ammer_haxe_string_type = ex_string->t;
  _ammer_haxe_scb = scb;
  hl_add_root(&_ammer_haxe_scb);
}
DEFINE_PRIM(_VOID, _ammer_init, _OBJ(_I32 _I32) _OBJ(_BYTES _I32) _ARR);');
    #end
  }

  override function finalise(platConfig:HashlinkConfig):Void {
    var scbInit = [ for (id => cb in staticCallbackIds) {
      macro scb[$v{id}] = $p{tdefStaticCallbacks.pack.concat([tdefStaticCallbacks.name])}.$cb;
    } ];
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          var scb = new hl.NativeArray<Any>($v{staticCallbackIds.length});
          $b{scbInit};
          _ammer_init(
            #if !(haxe >= version("4.2.6") && hl_ver >= version("1.12.0") && !hl_legacy32)
            haxe.Int64.make(0, 0),
            #end
            "",
            scb
          );
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    outputPathRelative = platConfig.hlc ? 'lib${config.name}.%DLL%' : '${config.name}.hdll';
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ai('HL_PRIM ${ret.l1Type} HL_NAME($name)(')
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
    lb
      .ai('DEFINE_PRIM(${ret.hlType}, $name, ')
      .map(args, arg -> arg.hlType, " ")
      .a(args.length == 0 ? "_NO_ARG" : "")
      .al(');');
    tdef.fields.push({
      pos: options.pos,
      name: name,
      meta: [{
        pos: options.pos,
        params: [
          macro $v{config.name},
          macro $v{name},
        ],
        name: ":hlNative",
      }],
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType, macro throw 0),
      access: [APublic, AStatic],
    });
    return fieldExpr(name);
  }

  function baseCall(
    lb:LineBuf,
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>,
    outputExpr:String,
    argExprs:Array<String>
  ):Void {
    lb
      .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l3l2(argExprs[idx], '_l2_arg_$idx'))
      .lmapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
      .ifi(ret.mangled != "v")
        .ail('${ret.l1Type} _l1_output;')
        .ail('_l1_output = (_l1_fn->hasValue')
      .ife()
        .ail('(_l1_fn->hasValue')
      .ifd()
      .i()
        .ai('? ((${ret.l1Type} (*)(vdynamic *')
        .map(args, arg -> ', ${arg.l1Type}')
        .a('))(_l1_fn->fun))(_l1_fn->value')
        .mapi(args, (idx, arg) -> ', _l1_arg_${idx}')
        .al(")")
        .ai(': ((${ret.l1Type} (*)(')
        .map(args, arg -> arg.l1Type, ", ")
        .a('))(_l1_fn->fun))(')
        .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
        .al("));")
      .d()
      .ifi(ret.mangled != "v")
        .ail('${ret.l2Type} _l2_output;')
        .ail(ret.l1l2("_l1_output", "_l2_output"))
        .ail(ret.l2l3("_l2_output", outputExpr))
      .ifd();
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<HashlinkTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    return new LineBuf()
      .ail("do {")
      .i()
        .ail('${clType.type.l2Type} _l2_fn;')
        .ail(clType.type.l3l2(fn, "_l2_fn"))
        .ail("_ammer_haxe_ref* _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("vclosure* _l1_fn;")
        .ail("_l1_fn = _l1_fn_ref->value;")
        .apply(baseCall.bind(_, clType.ret, clType.args, outputExpr, args))
      .d()
      .ail("} while (0);")
      .done();
  }

  public function staticCall(
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    var name = baseStaticCall(ret, args, code);
    var scbId = staticCallbackIds.length;
    staticCallbackIds.push(name);
    return new LineBuf()
      .ail("do {")
      .i()
        .ail('vclosure* _l1_fn = hl_aptr(_ammer_haxe_scb, vclosure*)[$scbId];')
        .apply(baseCall.bind(_, ret, args, outputExpr, argExprs))
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
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

@:allow(ammer.core.plat)
class HashlinkMarshal extends BaseMarshal<
  HashlinkMarshal,
  Hashlink,
  HashlinkConfig,
  HashlinkLibraryConfig,
  HashlinkLibrary,
  HashlinkTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    ext:HashlinkTypeMarshalExt,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):HashlinkTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      l1Type:    over != null && over.l1Type    != null ? over.l1Type    : base.l1Type,
      l2Type:    over != null && over.l2Type    != null ? over.l2Type    : base.l2Type,
      l3Type:    over != null && over.l3Type    != null ? over.l3Type    : base.l3Type,
      mangled:   over != null && over.mangled   != null ? over.mangled   : base.mangled,
      l1l2:      over != null && over.l1l2      != null ? over.l1l2      : base.l1l2,
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
      hlType:    ext.hlType,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid(), {hlType: "_VOID"});
  public function void():HashlinkTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {hlType: "_BOOL"});
  public function bool():HashlinkTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    // TODO: no direct array for 8-bit ints: causes JIT error
    // arrayType: (macro : hl.UI8),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    // arrayType: (macro : hl.UI8),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    arrayType: (macro : hl.UI16),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    arrayType: (macro : hl.UI16),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    arrayType: (macro : Int),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {hlType: "_I32"}, {
    l1Type: "int32_t",
    arrayType: (macro : Int),
  });
  public function uint8():HashlinkTypeMarshal return MARSHAL_UINT8;
  public function int8():HashlinkTypeMarshal return MARSHAL_INT8;
  public function uint16():HashlinkTypeMarshal return MARSHAL_UINT16;
  public function int16():HashlinkTypeMarshal return MARSHAL_INT16;
  public function uint32():HashlinkTypeMarshal return MARSHAL_UINT32;
  public function int32():HashlinkTypeMarshal return MARSHAL_INT32;

  #if (haxe >= version("4.2.6") && hl_ver >= version("1.12.0") && !hl_legacy32)
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {hlType: "_I64"}, {
    l1Type: "uint64_t",
    // TODO: JIT errors and no ArrayBytes<I64> (Haxe#10725)
    // arrayType: (macro : hl.I64), //haxe.Int64),
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshal.baseInt64(), {hlType: "_I64"}, {
    l1Type: "int64_t",
    // arrayType: (macro : hl.I64), //haxe.Int64),
  });
  #else
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {hlType: "_OBJ(_I32 _I32)"}, {
    l1Type: "_ammer_haxe_int64*",
    l1l2: (l1, l2) -> '$l2 = (((uint64_t)$l1->high) << 32) | (uint32_t)$l1->low;',
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_int64*)hl_alloc_obj(_ammer_haxe_int64_type);
$l1->high = (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF);
$l1->low = (int32_t)($l2 & 0xFFFFFFFF);',
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshal.baseInt64(), {hlType: "_OBJ(_I32 _I32)"}, {
    l1Type: "_ammer_haxe_int64*",
    l1l2: (l1, l2) -> '$l2 = (((int64_t)$l1->high) << 32) | (uint32_t)$l1->low;',
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_int64*)hl_alloc_obj(_ammer_haxe_int64_type);
$l1->high = (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF);
$l1->low = (int32_t)($l2 & 0xFFFFFFFF);',
  });
  #end

  public function uint64():HashlinkTypeMarshal return MARSHAL_UINT64;
  public function int64():HashlinkTypeMarshal return MARSHAL_INT64;

  public function enumInt(name:String, type:HashlinkTypeMarshal):HashlinkTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {hlType: type.hlType});

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {hlType: "_F32"}, {
    arrayType: (macro : hl.F32),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {hlType: "_F64"}, {
    arrayType: (macro : Float),
  });
  public function float32():HashlinkTypeMarshal return MARSHAL_FLOAT32;
  public function float64():HashlinkTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {hlType: "_OBJ(_BYTES _I32)"}, {
    l1Type: "_ammer_haxe_string*",
    l1l2: (l1, l2) -> '$l2 = hl_to_utf8((const uchar*)$l1->data);',
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_string*)hl_alloc_obj(_ammer_haxe_string_type);
$l1->len = hl_utf8_length((const unsigned char*)$l2, 0);
$l1->data = hl_gc_alloc_noptr(($l1->len + 1) * sizeof(uchar));
hl_from_utf8((uchar*)$l1->data, $l1->len, $l2);', // TODO: handle null?
  });
  public function string():HashlinkTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {hlType: "_BYTES"}, {
    haxeType: (macro : hl.Bytes),
    l1Type: "vbyte*",
  });
  function bytesInternalType():HashlinkTypeMarshal return MARSHAL_BYTES;
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
      (macro : hl.Bytes), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        var _ret = new hl.Bytes(_size);
        _ret.blit(0, _self, 0, _size);
        _ret.toBytes(_size);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = $e{alloc(macro _bytes.length)};
        _ret.blit(0, @:privateAccess _bytes.b, 0, _bytes.length);
        _ret;
      },

      toHaxeRef: (self, size) -> macro {
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        _self.toBytes(_size);
      },
      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr = @:privateAccess _bytes.b;
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },

      // TODO: provide overrides for blit, get/set ...
    };
  }

  function opaqueInternal(name:String):HashlinkTypeMarshal {
    var mname = Mangle.identifier(name);
    var haxeType:ComplexType = TPath({
      // no prefix results in collisions with other type declarations
      // TODO: name with _ammer prefix
      params: [TPExpr(macro $v{"abstract_" + mname})],
      pack: ["hl"],
      name: "Abstract",
    });
    return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
      hlType: '_ABSTRACT(abstract_$mname)',
    }, {
      haxeType: haxeType,
    });
  }

  function structPtrDerefInternal(name:String):HashlinkTypeMarshal {
    var mname = Mangle.identifier('$name*');
    var haxeType:ComplexType = TPath({
      // no prefix results in collisions with other type declarations
      // TODO: name with _ammer prefix
      params: [TPExpr(macro $v{"abstract_" + mname})],
      pack: ["hl"],
      name: "Abstract",
    });
    return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
      hlType: '_ABSTRACT(abstract_$mname)',
    }, {
      haxeType: haxeType,
    });
  }

  function arrayPtrInternalType(element:HashlinkTypeMarshal):HashlinkTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    hlType: "_BYTES",
  }, {
    haxeType: (macro : hl.Bytes),
    l1Type: "vbyte*",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST('${element.l2Type}*'),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("vbyte*"),
  });
  override function arrayPtrInternalOps(
    type:HashlinkTypeMarshal,
    element:HashlinkTypeMarshal,
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
      (macro : hl.Bytes), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      vectorType: vectorType,
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        var bytes = new hl.Bytes(_size << $v{element.arrayBits});
        bytes.blit(0, _self, 0, _size << $v{element.arrayBits});
        var bytesAccess:hl.BytesAccess<$elType> = bytes;
        var _ret = new hl.types.ArrayBytes<$elType>(); // use untyped $new ?
        @:privateAccess _ret.bytes = bytesAccess;
        @:privateAccess _ret.length = _size;
        @:privateAccess _ret.size = _size;
        (cast _ret : $vectorType);
      },
      fromHaxeCopy: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        var _ret = $e{alloc(macro _vector.length << $v{element.arrayBits})};
        _ret.blit(
          0,
          @:privateAccess (cast _vector.toData() : hl.types.ArrayBytes<$elType>).bytes,
          0,
          _vector.length << $v{element.arrayBits}
        );
        _ret;
      },
      toHaxeRef: (self, size) -> macro {
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        var bytesAccess:hl.BytesAccess<$elType> = _self;
        var _ret = new hl.types.ArrayBytes<$elType>(); // use untyped $new ?
        @:privateAccess _ret.bytes = bytesAccess;
        @:privateAccess _ret.length = _size;
        @:privateAccess _ret.size = _size;
        (cast _ret : $vectorType);
      },
      fromHaxeRef: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        var _ptr = @:privateAccess (cast _vector.toData() : hl.types.ArrayBytes<$elType>).bytes;
        (@:privateAccess new $pathArrayRef(_vector, _ptr, 0));
      },
    };
  }

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<HashlinkTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : hl.Abstract<"abstract_haxe_ref">),
      macro null,
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getvalue")})(handle),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getcount")})(handle),
      rc -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_setcount")})(handle, $rc),
      value -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_create")})($value),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_delete")})(handle)
    );
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):HashlinkTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    hlType: "_ABSTRACT(abstract_haxe_ref)",
  }, {
    haxeType: (macro : hl.Abstract<"abstract_haxe_ref">),
    l1Type: "_ammer_haxe_ref*",
  });

  public function new(library:HashlinkLibrary) {
    super(library);
  }
}

#end
