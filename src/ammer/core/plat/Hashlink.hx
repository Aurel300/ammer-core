package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

@:allow(ammer.core.plat.Hashlink)
class HashlinkMarshalSet extends BaseMarshalSet<
  HashlinkMarshalSet,
  HashlinkLibraryConfig,
  HashlinkLibrary,
  HashlinkTypeMarshal
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

  static final MARSHAL_VOID:HashlinkTypeMarshal = {
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
    hlType: "_VOID",
  };

  static final MARSHAL_BOOL:HashlinkTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "bool",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_BOOL",
  };

  static final MARSHAL_UINT8:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "uint8_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_INT8:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "int8_t",
    l3Type: "int8_t",
    mangled: "i16",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_UINT16:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "uint16_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_INT16:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "int16_t",
    l3Type: "int16_t",
    mangled: "i16",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_UINT32:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_INT32:HashlinkTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_I32",
  };
  static final MARSHAL_UINT64:HashlinkTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "_ammer_haxe_int64*",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: (l1, l2) -> '$l2 = (((uint64_t)$l1->high) << 32) | (uint32_t)$l1->low;',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_int64*)hl_alloc_obj(_ammer_haxe_int64_type);
$l1->high = (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF);
$l1->low = (int32_t)($l2 & 0xFFFFFFFF);',
    hlType: "_OBJ(_I32 _I32)",
  };
  static final MARSHAL_INT64:HashlinkTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "_ammer_haxe_int64*",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
    l1l2: (l1, l2) -> '$l2 = (((int64_t)$l1->high) << 32) | (uint32_t)$l1->low;',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_int64*)hl_alloc_obj(_ammer_haxe_int64_type);
$l1->high = (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF);
$l1->low = (int32_t)($l2 & 0xFFFFFFFF);',
    hlType: "_OBJ(_I32 _I32)",
  };

  static final MARSHAL_FLOAT32:HashlinkTypeMarshal = {
    haxeType: (macro : Single),
    l1Type: "float",
    l2Type: "float",
    l3Type: "float",
    mangled: "f32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_F32",
  };
  static final MARSHAL_FLOAT64:HashlinkTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "double",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_F64",
  };

  static final MARSHAL_STRING:HashlinkTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "_ammer_haxe_string*",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: (l1, l2) -> '$l2 = hl_to_utf8($l1->data);',
    l2ref: MARSHAL_NOOP1, // TODO: might need to GC root ?
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1, // TODO: dealloc?
    l2l1: (l2, l1) -> '$l1 = (_ammer_haxe_string*)hl_alloc_obj(_ammer_haxe_string_type);
$l1->len = hl_utf8_length($l2, 0);
$l1->data = (uchar*)hl_gc_alloc_noptr(($l1->len + 1) * sizeof(uchar));
hl_from_utf8($l1->data, $l1->len, $l2);', // TODO: handle null?
    hlType: "_OBJ(_BYTES _I32)",
  };

  static final MARSHAL_BYTES:HashlinkTypeMarshal = {
    haxeType: (macro : hl.Bytes),
    l1Type: "vbyte*",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: "_BYTES",
  };

  public function new(library:HashlinkLibrary) {
    super(library);
  }

  public function void():HashlinkTypeMarshal return MARSHAL_VOID;

  public function bool():HashlinkTypeMarshal return MARSHAL_BOOL;

  public function uint8():HashlinkTypeMarshal return MARSHAL_UINT8;
  public function int8():HashlinkTypeMarshal return MARSHAL_INT8;
  public function uint16():HashlinkTypeMarshal return MARSHAL_UINT16;
  public function int16():HashlinkTypeMarshal return MARSHAL_INT16;
  public function uint32():HashlinkTypeMarshal return MARSHAL_UINT32;
  public function int32():HashlinkTypeMarshal return MARSHAL_INT32;
  public function uint64():HashlinkTypeMarshal return MARSHAL_UINT64;
  public function int64():HashlinkTypeMarshal return MARSHAL_INT64;

  public function float32():HashlinkTypeMarshal return MARSHAL_FLOAT32;
  public function float64():HashlinkTypeMarshal return MARSHAL_FLOAT64;

  public function string():HashlinkTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():HashlinkTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:HashlinkTypeMarshal,
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
      public var ptr(default, null):hl.Bytes;
      public function unref():Void {
        if (bytes != null) {
          bytes = null;
          ptr = null;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:hl.Bytes) {
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
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        var _ret = haxe.io.Bytes.alloc(_size); // TODO: does this zero unnecessarily?
        $e{blit(
          macro _self, macro 0,
          macro @:privateAccess _ret.b, macro 0,
          macro _size
        )};
        _ret;
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = $e{alloc(macro _bytes.length)};
        $e{blit(
          macro @:privateAccess _bytes.b, macro 0,
          macro _ret, macro 0,
          macro _bytes.length
        )};
        _ret;
      },

      toBytesRef: (self, size) -> macro {
        var _self = ($self : hl.Bytes);
        var _size = ($size : Int);
        _self.toBytes(_size);
      },
      fromBytesRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr = @:privateAccess _bytes.b;
        (@:privateAccess new $pathBytesRef(_bytes, _ptr));
      },
    };
  }

  function opaquePtrInternal(name:String):HashlinkTypeMarshal return {
    haxeType: TPath({
      // no prefix results in collisions with other type declarations
      // TODO: name with _ammer prefix
      params: [TPExpr(macro $v{"abstract_" + name})],
      pack: ["hl"],
      name: "Abstract",
    }),
    l1Type: '$name*',
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    hlType: '_ABSTRACT(abstract_$name)',
  };

  function haxePtrInternal(haxeType:ComplexType):HashlinkTypeMarshal return {
    // TODO: would be nice to avoid boxing
    //       but maybe this requires a post-typing interface ...
    haxeType: (macro : Dynamic),
    l1Type: "vdynamic*",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
    hlType: "_DYN",
  };

  function closureInternal(
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>
  ):HashlinkTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "vclosure*",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
    hlType: '_FUN(${ret.hlType}, ' + (args.length == 0 ? "_NO_ARG" : args.map(arg -> arg.hlType).join(" ")) + ')',
  };
}

class Hashlink extends Base<
  HashlinkConfig,
  HashlinkLibraryConfig,
  HashlinkTypeMarshal,
  HashlinkLibrary,
  HashlinkMarshalSet
> {
  public function new(config:HashlinkConfig) {
    super("hl", config);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.hlIncludePaths,
      libraryPaths: config.hlLibraryPaths,
      linkNames: ["hl"],
      defines: ["LIBHL_EXPORTS"],
      outputPath: lib -> config.hlc
        ? '${config.outputPath}/lib${lib.config.name}.%DLL%'
        : '${config.outputPath}/${lib.config.name}.hdll',
      libCode: lib -> lib.lb
        .ail("void HL_NAME(_ammer_init)(_ammer_haxe_int64 *ex_int64, _ammer_haxe_string *ex_string) {")
        .i()
          .ail("_ammer_haxe_int64_type = ex_int64->t;")
          .ail("_ammer_haxe_string_type = ex_string->t;")
        .d()
        .ail("}")
        .ail('DEFINE_PRIM(_VOID, _ammer_init, _OBJ(_I32 _I32) _OBJ(_BYTES _I32));')
        .done(),
    });
  }
}

@:structInit
class HashlinkConfig extends BaseConfig {
  public var hlc:Bool = false;
  public var hlIncludePaths:Array<String> = null;
  public var hlLibraryPaths:Array<String> = null;
}

@:allow(ammer.core.plat.Hashlink)
class HashlinkLibrary extends BaseLibrary<
  HashlinkLibrary,
  HashlinkLibraryConfig,
  HashlinkTypeMarshal,
  HashlinkMarshalSet
> {
  public function new(config:HashlinkLibraryConfig) {
    super(config, new HashlinkMarshalSet(this));
    tdef.fields.push({
      pos: Context.currentPos(),
      name: "_ammer_init",
      meta: [{
        pos: Context.currentPos(),
        params: [
          macro $v{config.name},
          macro "_ammer_init",
        ],
        name: ":hlNative",
      }],
      kind: FFun({
        ret: (macro : Void),
        expr: macro throw 0,
        args: [{
          type: (macro : haxe.Int64),
          name: "ex_int64",
        }, {
          type: (macro : String),
          name: "ex_string",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          _ammer_init(
            haxe.Int64.make(0, 0),
            ""
          );
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    lb.ail('#define HL_NAME(n) ${config.name}_ ## n');
    lb.ail("#include \"hl.h\"");
    //lb.ail("#include <inttypes.h>");
    boilerplate(
      "void*",
      "void*",
      "",
      // TODO: GC moving curr->key would break things (different hash bin)
      "hl_add_root(&curr->key);",
      "hl_remove_root(&curr->key);"
    );
    // TODO: could be nicer with a union?
    lb.ail("typedef struct { hl_type *t; int32_t high; int32_t low; } _ammer_haxe_int64;");
    lb.ail("static hl_type *_ammer_haxe_int64_type;");
    lb.ail("typedef struct { hl_type *t; vbyte *data; int32_t len; } _ammer_haxe_string;");
    lb.ail("static hl_type *_ammer_haxe_string_type;");
  }

  public function addFunction(
    ret:HashlinkTypeMarshal,
    args:Array<HashlinkTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
    lb
      .ai('HL_PRIM ${ret.l1Type} HL_NAME($name)(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_$idx', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_l1_arg_$idx', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != HashlinkMarshalSet.MARSHAL_VOID)
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
        .ifd()
      .d()
      .al("}");
    lb
      .ai('DEFINE_PRIM(${ret.hlType}, $name, ')
      .map(args, arg -> arg.hlType, " ")
      .a(args.length == 0 ? "_NO_ARG" : "")
      .al(');');
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
      kind: FFun({
        ret: ret.haxeType,
        expr: macro throw 0,
        args: [ for (i => arg in args) {
          type: arg.haxeType,
          name: 'arg$i',
        } ],
      }),
      access: [APublic, AStatic],
    });
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<HashlinkTypeMarshal>,
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
        .ifi(clType.ret != HashlinkMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l1Type} _l1_output;')
          .ail('_l1_output = (_l1_fn->hasValue')
        .ife()
          .ail('(_l1_fn->hasValue')
        .ifd()
        .i()
          .ai('? ((${clType.ret.l1Type} (*)(vdynamic *')
          .map(clType.args, arg -> ', ${arg.l1Type}')
          .a('))(_l1_fn->fun))(_l1_fn->value')
          .map(args, arg -> ', ${arg}')
          .al(")")
          .ai(': ((${clType.ret.l1Type} (*)(')
          .map(clType.args, arg -> arg.l1Type, ", ")
          .a('))(_l1_fn->fun))(')
          .map(args, arg -> arg, ", ")
          .al("));")
        .d()
        .ifi(clType.ret != HashlinkMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ifd()
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
      .ifi(ret != HashlinkMarshalSet.MARSHAL_VOID)
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

typedef HashlinkLibraryConfig = LibraryConfig;
typedef HashlinkTypeMarshal = {
  >BaseTypeMarshal,
  hlType:String,
};

#end
