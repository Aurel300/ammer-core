package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

@:structInit
class NekoConfig extends BaseConfig {
  public var nekoIncludePaths:Array<String> = null;
  public var nekoLibraryPaths:Array<String> = null;
}

typedef NekoLibraryConfig = LibraryConfig;

typedef NekoTypeMarshal = BaseTypeMarshal;

class Neko extends Base<
  Neko,
  NekoConfig,
  NekoLibraryConfig,
  NekoTypeMarshal,
  NekoLibrary,
  NekoMarshal
> {
  public function new(config:NekoConfig) {
    super("neko", config);
  }

  public function createLibrary(libConfig:NekoLibraryConfig):NekoLibrary {
    return new NekoLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.nekoIncludePaths,
      libraryPaths: config.nekoLibraryPaths,
      linkNames: ["neko"],
      outputPath: lib -> '${config.outputPath}/${lib.config.name}.ndll',
    });
  }
}

@:allow(ammer.core.plat)
class NekoLibrary extends BaseLibrary<
  NekoLibrary,
  Neko,
  NekoConfig,
  NekoLibraryConfig,
  NekoTypeMarshal,
  NekoMarshal
> {
  var abstractKinds = new Map();

  function pushNative(name:String, argCount:Int, pos:Position):Void {
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: FVar(
        (macro : Dynamic),
        macro neko.Lib.loadLazy($v{config.name}, $v{name}, $v{argCount})
      ),
      access: [APrivate, AStatic],
    });
  }

  public function new(platform:Neko, config:NekoLibraryConfig) {
    super(platform, config, new NekoMarshal(this));
    pushNative("_ammer_neko_tohaxecopy", 2, config.pos);
    pushNative("_ammer_neko_fromhaxecopy", 2, config.pos);
    pushNative("_ammer_neko_fromhaxeref", 1, config.pos);

    pushNative("_ammer_ref_create",   1, config.pos);
    pushNative("_ammer_ref_delete",   1, config.pos);
    pushNative("_ammer_ref_getcount", 1, config.pos);
    pushNative("_ammer_ref_setcount", 2, config.pos);
    pushNative("_ammer_ref_getvalue", 1, config.pos);

    pushNative("_ammer_init", 2, config.pos);
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          _ammer_init(haxe.Int64.make(0, 0), "");
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    lb.ail("#include <neko.h>");
    lb.ail('static vobject *_ammer_haxe_proto_int64;');
    lb.ail('static field _ammer_haxe_field_high;');
    lb.ail('static field _ammer_haxe_field_low;');
    lb.ail('static vobject *_ammer_haxe_proto_string;');
    lb.ail('static field _ammer_haxe_field_string;');
    lb.ail('DEFINE_KIND(_neko_abstract_bytes);');
    lb.ail('DEFINE_KIND(_neko_abstract_haxe_ref);');
    lb.ail('static value _ammer_neko_tohaxecopy(value data, value size) {
  return copy_string((const char*)(int_val)val_data(data), val_any_int(size));
}
DEFINE_PRIM(_ammer_neko_tohaxecopy, 2);
static value _ammer_neko_fromhaxecopy(value data, value w_size) {
  uint32_t size = val_any_int(w_size);
  uint8_t* ret = (uint8_t*)${config.mallocFunction}(size);
  ${config.memcpyFunction}(ret, val_string(data), size);
  return alloc_abstract(_neko_abstract_bytes, (value)(int_val)(ret));
}
DEFINE_PRIM(_ammer_neko_fromhaxecopy, 2);
static value _ammer_neko_fromhaxeref(value data) {
  return alloc_abstract(_neko_abstract_bytes, (value)(int_val)(val_string(data)));
}
DEFINE_PRIM(_ammer_neko_fromhaxeref, 1);

typedef struct { value* data; int32_t refcount; } _ammer_haxe_ref;
static value _ammer_ref_create(value obj) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  // TODO: remove double allocation?
  ref->data = alloc_root(1);
  *ref->data = obj;
  ref->refcount = 0;
  return alloc_abstract(_neko_abstract_haxe_ref, (value)(int_val)ref);
}
DEFINE_PRIM(_ammer_ref_create, 1);
static void _ammer_ref_delete(value vref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(int_val)val_data(vref);
  free_root(ref->data);
  ref->data = NULL;
  ${config.freeFunction}(ref);
}
DEFINE_PRIM(_ammer_ref_delete, 1);
static value _ammer_ref_getcount(value vref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(int_val)val_data(vref);
  return alloc_int32(ref->refcount);
}
DEFINE_PRIM(_ammer_ref_getcount, 1);
static void _ammer_ref_setcount(value vref, value wrc) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(int_val)val_data(vref);
  ref->refcount = val_any_int(wrc);
}
DEFINE_PRIM(_ammer_ref_setcount, 2);
static value _ammer_ref_getvalue(value vref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(int_val)val_data(vref);
  return *ref->data;
}
DEFINE_PRIM(_ammer_ref_getvalue, 1);
');
  }

  override function finalise(platConfig:NekoConfig):Void {
    // TODO: name symbols with internalPrefix
    lb
      .ail('static value _ammer_init(value ex_int64, value ex_string) {
  _ammer_haxe_proto_int64 = ((vobject *)ex_int64)->proto;
  _ammer_haxe_field_high = val_id("high");
  _ammer_haxe_field_low = val_id("low");
  _ammer_haxe_proto_string = ((vobject *)ex_string)->proto;
  _ammer_haxe_field_string = val_id("__s");
  return val_null;
}
DEFINE_PRIM(_ammer_init, 2);');
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:NekoTypeMarshal,
    args:Array<NekoTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    // unfortunately Neko's `val_call` does not deal with more than 5 arguments,
    // and it seems to be used when calling the result of `loadLazy`
    if (args.length > 5) {
      lb
        .ail('static value ${name}(value _neko_args) {')
        .i();
      baseAddNamedFunction(
        args,
        args.mapi((idx, arg) -> 'val_array_ptr(_neko_args)[$idx]'),
        ret,
        "_l1_return",
        code,
        lb,
        options
      );
      lb
          .ifi(ret.mangled != "v")
            .ail('return _l1_return;')
          .ife()
            .ail("return val_null;")
          .ifd()
        .d()
        .ail("}")
        .ail('DEFINE_PRIM(${name}, 1);');
      tdef.fields.push({
        pos: options.pos,
        name: '_ammer_args_$name', // TODO: better name?
        kind: FVar(
          TFunction([(macro : neko.NativeArray<Any>)], ret.haxeType),
          macro neko.Lib.loadLazy($v{config.name}, $v{name}, 1)
        ),
        access: [APublic, AStatic],
      });
      var nekoArgs:Expr = {
        expr: EArrayDecl([ for (idx in 0...args.length) macro $i{'_arg$idx'} ]),
        pos: options.pos,
      };
      tdef.fields.push({
        pos: options.pos,
        name: name,
        kind: FFun({
          ret: ret.haxeType,
          expr: macro {
            var args = neko.NativeArray.ofArrayRef(($nekoArgs:Array<Dynamic>));
            return $e{fieldExpr('_ammer_args_$name')}(args);
          },
          args: args.mapi((idx, arg) -> ({ name: '_arg$idx', type: arg.haxeType } : FunctionArg)),
        }),
        access: [APublic, AStatic],
      });
    } else {
      lb
        .ai('static value ${name}(')
        .mapi(args, (idx, arg) -> 'value _l1_arg_$idx', ", ")
        .a(args.length == 0 ? "void" : "")
        .al(') {')
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
          .ife()
            .ail("return val_null;")
          .ifd()
        .d()
        .ail("}")
        .ail('DEFINE_PRIM(${name}, ${args.length});');
      tdef.fields.push({
        pos: options.pos,
        name: name,
        kind: FVar(
          TFunction(args.map(arg -> arg.haxeType), ret.haxeType),
          macro neko.Lib.loadLazy($v{config.name}, $v{name}, $v{args.length})
        ),
        access: [APublic, AStatic],
      });
    }
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<NekoTypeMarshal>,
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
        .ail("value _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail('${clType.type.l1Type} _l1_fn;')
        .ail("_l1_fn = *(((_ammer_haxe_ref*)(int_val)val_data(_l1_fn_ref))->data);")
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ifi(args.length > 0)
          .ail('value _neko_args[${args.length}] = {')
          .lmapi(args, (idx, arg) -> '_l1_arg_$idx,')
          .ail("};")
        .ifd()
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai('_l1_output = val_callN(_l1_fn, ')
          .a(args.length > 0 ? "_neko_args" : "NULL")
          .al(', ${args.length});')
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ife()
          .ai('val_callN(_l1_fn, ')
          .a(args.length > 0 ? "_neko_args" : "NULL")
          .al(', ${args.length});')
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:NekoTypeMarshal,
    args:Array<NekoTypeMarshal>,
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
class NekoMarshal extends BaseMarshal<
  NekoMarshal,
  Neko,
  NekoConfig,
  NekoLibraryConfig,
  NekoLibrary,
  NekoTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):NekoTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "value", a Neko tagged pointer
      l1Type:   "value",
      l2Type:    over != null && over.l2Type    != null ? over.l2Type    : base.l2Type,
      l3Type:    over != null && over.l3Type    != null ? over.l3Type    : base.l3Type,
      mangled:   over != null && over.mangled   != null ? over.mangled   : base.mangled,
      l1l2:      over != null && over.l1l2      != null ? over.l1l2      : base.l1l2,
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
    };
  }

  static final MARSHAL_VOID = BaseMarshal.baseVoid();
  public function void():NekoTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
    l1l2: (l1, l2) -> '$l2 = val_bool($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_bool($l2);',
  });
  public function bool():NekoTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  });
  public function uint8():NekoTypeMarshal return MARSHAL_UINT8;
  public function int8():NekoTypeMarshal return MARSHAL_INT8;
  public function uint16():NekoTypeMarshal return MARSHAL_UINT16;
  public function int16():NekoTypeMarshal return MARSHAL_INT16;
  public function uint32():NekoTypeMarshal return MARSHAL_UINT32;
  public function int32():NekoTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    l1l2: (l1, l2) -> '$l2 = ((uint64_t)val_any_int(val_field($l1, _ammer_haxe_field_high)) << 32) | (uint32_t)val_any_int(val_field($l1, _ammer_haxe_field_low));',
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_int64;
alloc_field($l1, _ammer_haxe_field_high, alloc_int32(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
alloc_field($l1, _ammer_haxe_field_low, alloc_int32($l2 & 0xFFFFFFFF));',
  });
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(), {
    l1l2: (l1, l2) -> '$l2 = ((int64_t)val_any_int(val_field($l1, _ammer_haxe_field_high)) << 32) | (uint32_t)val_any_int(val_field($l1, _ammer_haxe_field_low));',
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_int64;
alloc_field($l1, _ammer_haxe_field_high, alloc_int32(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
alloc_field($l1, _ammer_haxe_field_low, alloc_int32($l2 & 0xFFFFFFFF));',
  });
  public function uint64():NekoTypeMarshal return MARSHAL_UINT64;
  public function int64():NekoTypeMarshal return MARSHAL_INT64;

  // static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {
  //   l1l2: (l1, l2) -> '$l2 = val_float($l1);',
  //   l2l1: (l2, l1) -> '$l1 = alloc_float($l2);',
  // });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    //l1l2: (l1, l2) -> '$l2 = val_float($l1);',
    l1l2: (l1, l2) -> '$l2 = val_number($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_float($l2);',
  });
  public function float32():NekoTypeMarshal return throw "!";
  public function float64():NekoTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    l1l2: (l1, l2) -> '$l2 = val_string(val_field($l1, _ammer_haxe_field_string));',
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_string;
alloc_field($l1, _ammer_haxe_field_string, alloc_string($l2));',
  });
  public function string():NekoTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : Dynamic),
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)(int_val)val_data($l1);',
    l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_bytes, (value)(int_val)($l2));',
  });
  function bytesInternalType():NekoTypeMarshal return MARSHAL_BYTES;
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
      (macro : Int), macro 0,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : Dynamic);
        var _size = ($size : Int);
        var _data = ((untyped $e{library.fieldExpr("_ammer_neko_tohaxecopy")}) : (Dynamic, Int) -> neko.NativeString)(
          _self,
          _size
        );
        haxe.io.Bytes.ofData(_data);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_neko_fromhaxecopy")}) : (neko.NativeString, Int) -> Dynamic)(
          _bytes.getData(),
          _bytes.length
        );
        (_ret : Dynamic);
      },

      toHaxeRef: null,
      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_neko_fromhaxeref")}) : (neko.NativeString) -> Dynamic)(
          _bytes.getData()
        );
        (@:privateAccess new $pathBytesRef(_bytes, _ret, 0));
      },
    };
  }

  function opaqueInternal(name:String):MarshalOpaque<NekoTypeMarshal> {
    var mname = Mangle.identifier(name);
    if (!library.abstractKinds.exists(name)) {
      library.lb.ail('DEFINE_KIND(_neko_abstract_kind_$mname);');
      library.abstractKinds[name] = true;
    }
    return {
      type: baseExtend(BaseMarshal.baseOpaquePtrInternal(name), {
        haxeType: (macro : Dynamic),
        l1l2: (l1, l2) -> '$l2 = ($name*)(int_val)val_data($l1);',
        l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_kind_$mname, (value)(int_val)($l2));',
      }),
      typeDeref: baseExtend(BaseMarshal.baseOpaqueDirectInternal(name), {
        haxeType: (macro : Dynamic),
        l1l2: (l1, l2) -> '$l2 = ($name*)(int_val)val_data($l1);',
        l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_kind_$mname, (value)(int_val)($l2));',
      }),
    };
  }

  function arrayPtrInternalType(element:NekoTypeMarshal):NekoTypeMarshal {
    var name = 'array_${element.mangled}'; // TODO: more robust name
    if (!library.abstractKinds.exists(name)) {
      library.lb.ail('DEFINE_KIND(_neko_abstract_kind_$name);');
      library.abstractKinds[name] = true;
    }
    return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
      haxeType: (macro : Dynamic),
      l1l2: (l1, l2) -> '$l2 = (${element.l2Type}*)(int_val)val_data($l1);',
      l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_kind_$name, (value)(int_val)($l2));',
    });
  }

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<NekoTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : Dynamic),
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

  function haxePtrInternalType(haxeType:ComplexType):NekoTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: (macro : Dynamic),
    l1Type: "_ammer_haxe_ref*",
    l1l2: (l1, l2) -> '$l2 = (_ammer_haxe_ref*)(int_val)val_data($l1);',
    l2l1: (l2, l1) -> 'if ($l2 == NULL) {
  $l1 = val_null;
} else {
  $l1 = alloc_abstract(_neko_abstract_haxe_ref, (value)(int_val)($l2));
}',
  });

  public function new(library:NekoLibrary) {
    super(library);
  }
}

#end
