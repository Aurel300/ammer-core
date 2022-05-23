package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

@:allow(ammer.core.plat.Neko)
class NekoMarshalSet extends BaseMarshalSet<
  NekoMarshalSet,
  NekoLibraryConfig,
  NekoLibrary,
  NekoTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

  // TODO: ${config.internalPrefix}
  static final MARSHAL_REGISTRY_GET_NODE = (l1:String, l2:String)
    -> '$l2 = _ammer_core_registry_get((void*)$l1);';
  static final MARSHAL_REGISTRY_REF = (l2:String)
    -> '_ammer_core_registry_incref($l2);';
  static final MARSHAL_REGISTRY_UNREF = (l2:String)
    -> '_ammer_core_registry_decref($l2);';
  static final MARSHAL_REGISTRY_GET_KEY = (l2:String, l1:String) // TODO: target type cast
    -> '$l1 = $l2->key;';

  static final MARSHAL_VOID:NekoTypeMarshal = {
    haxeType: (macro : Void),
    l1Type: "void",
    l2Type: "void",
    l3Type: "void",
    mangled: "v",
    l1l2: MARSHAL_NOOP2,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_NOOP2,
    l3l2: MARSHAL_NOOP2,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_NOOP2,
  };

  static final MARSHAL_BOOL:NekoTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "value",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: (l1, l2) -> '$l2 = val_bool($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_bool($l2);',
  };

  static final MARSHAL_UINT8:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "uint32_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_INT8:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "int32_t",
    l3Type: "int8_t",
    mangled: "i8",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_UINT16:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "uint32_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_INT16:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "int32_t",
    l3Type: "int16_t",
    mangled: "u16",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_UINT32:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_INT32:NekoTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "value",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: (l1, l2) -> '$l2 = val_any_int($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_int32($l2);',
  };
  static final MARSHAL_UINT64:NekoTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "value",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: (l1, l2) -> '$l2 = ((uint64_t)val_any_int(val_field($l1, _ammer_haxe_field_high)) << 32) | (uint32_t)val_any_int(val_field($l1, _ammer_haxe_field_low));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_int64;
alloc_field($l1, _ammer_haxe_field_high, alloc_int32(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
alloc_field($l1, _ammer_haxe_field_low, alloc_int32($l2 & 0xFFFFFFFF));',
  };
  static final MARSHAL_INT64:NekoTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "value",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
    l1l2: (l1, l2) -> '$l2 = ((int64_t)val_any_int(val_field($l1, _ammer_haxe_field_high)) << 32) | (uint32_t)val_any_int(val_field($l1, _ammer_haxe_field_low));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_int64;
alloc_field($l1, _ammer_haxe_field_high, alloc_int32(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
alloc_field($l1, _ammer_haxe_field_low, alloc_int32($l2 & 0xFFFFFFFF));',
  };

  // static final MARSHAL_FLOAT32:NekoTypeMarshal = {};
  static final MARSHAL_FLOAT64:NekoTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "value",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: (l1, l2) -> '$l2 = val_float($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_float($l2);',
  };

  static final MARSHAL_STRING:NekoTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "value",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: (l1, l2) -> '$l2 = val_string(val_field($l1, _ammer_haxe_field_string));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_object(NULL);
((vobject*)$l1)->proto = _ammer_haxe_proto_string;
alloc_field($l1, _ammer_haxe_field_string, alloc_string($l2));',
  };

  static final MARSHAL_BYTES:NekoTypeMarshal = {
    haxeType: (macro : Dynamic),
    l1Type: "value",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)(int_val)val_data($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_bytes, (value)(int_val)($l2));',
  };

  public function new(library:NekoLibrary) {
    super(library);
  }

  public function void():NekoTypeMarshal return MARSHAL_VOID;

  public function bool():NekoTypeMarshal return MARSHAL_BOOL;

  public function uint8():NekoTypeMarshal return MARSHAL_UINT8;
  public function int8():NekoTypeMarshal return MARSHAL_INT8;
  public function uint16():NekoTypeMarshal return MARSHAL_UINT16;
  public function int16():NekoTypeMarshal return MARSHAL_INT16;
  public function uint32():NekoTypeMarshal return MARSHAL_UINT32;
  public function int32():NekoTypeMarshal return MARSHAL_INT32;
  public function uint64():NekoTypeMarshal return MARSHAL_UINT64;
  public function int64():NekoTypeMarshal return MARSHAL_INT64;

  public function float32():NekoTypeMarshal return throw "!";
  public function float64():NekoTypeMarshal return MARSHAL_FLOAT64;

  public function string():NekoTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():NekoTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:NekoTypeMarshal,
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  } {
    var tdefBytesRef = library.typeDefCreate();
    tdefBytesRef.name += "_BytesRef";
    tdefBytesRef.fields = (macro class BytesRef {
      public var bytes(default, null):haxe.io.Bytes;
      public var ptr(default, null):Dynamic;
      public function unref():Void {
        if (bytes != null) {
          bytes = null;
          ptr = null;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:Dynamic) {
        this.bytes = bytes;
        this.ptr = ptr;
      }
    }).fields;
    var pathBytesRef:TypePath = {
      name: tdefBytesRef.name,
      pack: tdefBytesRef.pack,
    };
    return {
      toBytesCopy: (self, size) -> macro {
        var _self = ($self : Dynamic);
        var _size = ($size : Int);
        var _data = ((untyped $e{library.fieldExpr("_ammer_neko_tobytescopy")}) : (Dynamic, Int) -> neko.NativeString)(
          _self,
          _size
        );
        haxe.io.Bytes.ofData(_data);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_neko_frombytescopy")}) : (neko.NativeString, Int) -> Dynamic)(
          _bytes.getData(),
          _bytes.length
        );
        (_ret : Dynamic);
      },

      toBytesRef: null,
      fromBytesRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_neko_frombytesref")}) : (neko.NativeString) -> Dynamic)(
          _bytes.getData()
        );
        (@:privateAccess new $pathBytesRef(_bytes, _ret));
      },
    };
  }

  function opaquePtrInternal(name:String):NekoTypeMarshal {
    if (!library.abstractKinds.exists(name)) {
      library.lb.ail('DEFINE_KIND(_neko_abstract_kind_$name);');
      library.abstractKinds[name] = true;
    }
    return {
      haxeType: (macro : Dynamic),
      l1Type: "value",
      l2Type: '$name*',
      l3Type: '$name*',
      mangled: 'p${Mangle.identifier(name)}_',
      l1l2: (l1, l2) -> '$l2 = ($name*)(int_val)val_data($l1);',
      l2ref: MARSHAL_NOOP1,
      l2l3: MARSHAL_CONVERT_DIRECT,
      l3l2: MARSHAL_CONVERT_DIRECT,
      l2unref: MARSHAL_NOOP1,
      l2l1: (l2, l1) -> '$l1 = alloc_abstract(_neko_abstract_kind_$name, (value)(int_val)($l2));',
    };
  }

  function haxePtrInternal(haxeType:ComplexType):NekoTypeMarshal return {
    haxeType: (macro : Dynamic), // haxeType?
    l1Type: "value",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };

  function closureInternal(
    ret:NekoTypeMarshal,
    args:Array<NekoTypeMarshal>
  ):NekoTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "value",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };
}

class Neko extends Base<
  NekoConfig,
  NekoLibraryConfig,
  NekoTypeMarshal,
  NekoLibrary,
  NekoMarshalSet
> {
  public function new(config:NekoConfig) {
    super("neko", config);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.nekoIncludePaths,
      libraryPaths: config.nekoLibraryPaths,
      linkNames: ["neko"],
      outputPath: lib -> '${config.outputPath}/${lib.config.name}.ndll',
      libCode: lib -> lib.lb
        // TODO: name symbols with internalPrefix
        .ail('
static value _ammer_neko_tobytescopy(value data, value size) {
  return copy_string((const char*)(int_val)val_data(data), val_any_int(size));
}
DEFINE_PRIM(_ammer_neko_tobytescopy, 2);
static value _ammer_neko_frombytescopy(value data, value w_size) {
  uint32_t size = val_any_int(w_size);
  uint8_t* ret = (uint8_t*)malloc(size); // TODO: mallocFunction
  memcpy(ret, val_string(data), size);
  return alloc_abstract(_neko_abstract_bytes, (value)(int_val)(ret));
}
DEFINE_PRIM(_ammer_neko_frombytescopy, 2);
static value _ammer_neko_frombytesref(value data) {
  return alloc_abstract(_neko_abstract_bytes, (value)(int_val)(val_string(data)));
}
DEFINE_PRIM(_ammer_neko_frombytesref, 1);
static value _ammer_init(value ex_int64, value ex_string) {
  _ammer_haxe_proto_int64 = ((vobject *)ex_int64)->proto;
  _ammer_haxe_field_high = val_id("high");
  _ammer_haxe_field_low = val_id("low");
  _ammer_haxe_proto_string = ((vobject *)ex_string)->proto;
  _ammer_haxe_field_string = val_id("__s");
  return val_null;
}
DEFINE_PRIM(_ammer_init, 2);')
        .done(),
    });
  }
}

@:structInit
class NekoConfig extends BaseConfig {
  public var nekoIncludePaths:Array<String> = null;
  public var nekoLibraryPaths:Array<String> = null;
}

@:allow(ammer.core.plat.Neko)
class NekoLibrary extends BaseLibrary<
  NekoLibrary,
  NekoLibraryConfig,
  NekoTypeMarshal,
  NekoMarshalSet
> {
  var abstractKinds = new Map();

  public function new(config:NekoLibraryConfig) {
    super(config, new NekoMarshalSet(this));
    tdef.fields.push({
      pos: Context.currentPos(),
      name: "_ammer_neko_tobytescopy",
      kind: FVar(
        (macro : Dynamic),
        macro neko.Lib.loadLazy($v{config.name}, "_ammer_neko_tobytescopy", 2)
      ),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: Context.currentPos(),
      name: "_ammer_neko_frombytescopy",
      kind: FVar(
        (macro : Dynamic),
        macro neko.Lib.loadLazy($v{config.name}, "_ammer_neko_frombytescopy", 2)
      ),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: Context.currentPos(),
      name: "_ammer_neko_frombytesref",
      kind: FVar(
        (macro : Dynamic),
        macro neko.Lib.loadLazy($v{config.name}, "_ammer_neko_frombytesref", 1)
      ),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: Context.currentPos(),
      name: "_ammer_init",
      kind: FVar(
        (macro : Dynamic),
        macro neko.Lib.loadLazy($v{config.name}, "_ammer_init", 2)
      ),
      access: [APrivate, AStatic],
    });
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
    lb.ail("#include <inttypes.h>");
    boilerplate(
      "void*",
      "void*",
      "value* root;",
      // TODO: GC moving curr->key would break things (different hash bin)
      "curr->root = alloc_root(1);
*curr->root = curr->key;",
      "free_root(curr->root);"
    );
    lb.ail('static vobject *_ammer_haxe_proto_int64;');
    lb.ail('static field _ammer_haxe_field_high;');
    lb.ail('static field _ammer_haxe_field_low;');
    lb.ail('static vobject *_ammer_haxe_proto_string;');
    lb.ail('static field _ammer_haxe_field_string;');
    lb.ail('DEFINE_KIND(_neko_abstract_bytes);');
  }

  public function addFunction(
    ret:NekoTypeMarshal,
    args:Array<NekoTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
    lb
      .ai('static value ${name}(')
      .mapi(args, (idx, arg) -> 'value _l1_arg_$idx', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(') {')
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_l1_arg_$idx', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != NekoMarshalSet.MARSHAL_VOID)
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('${ret.l2Type} _l2_return;')
          .ail(ret.l3l2(config.returnIdent, "_l2_return"))
          .ail('${ret.l1Type} _l1_return;')
          .ail(ret.l2l1("_l2_return", "_l1_return"))
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail('return _l1_return;')
        .ife()
          .ail(code)
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail("return val_null;")
        .ifd()
      .d()
      .al("}")
      .ail('DEFINE_PRIM(${name}, ${args.length});');
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: FVar(
        TFunction(args.map(arg -> arg.haxeType), ret.haxeType),
        macro neko.Lib.loadLazy($v{config.name}, $v{name}, $v{args.length})
      ),
      access: [APublic, AStatic],
    });
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
        .ail('${clType.type.l1Type} _l1_fn;')
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn"))
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ail('value _neko_args[${args.length}] = {')
        .lmapi(args, (idx, arg) -> '_l1_arg_$idx,')
        .ail("};")
        .ifi(clType.ret != NekoMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l1Type} _l1_output;')
          .ail('_l1_output = val_callN(_l1_fn, _neko_args, ${args.length});')
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ife()
          .ail('val_callN(_l1_fn, _neko_args, ${args.length});')
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
        .ifi(ret != NekoMarshalSet.MARSHAL_VOID)
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

typedef NekoLibraryConfig = LibraryConfig;
typedef NekoTypeMarshal = BaseTypeMarshal;

#end
