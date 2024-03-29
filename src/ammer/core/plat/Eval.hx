package ammer.core.plat;

#if macro

@:structInit
class EvalConfig extends BaseConfig {
  public var haxeRepoPath:String;
}

typedef EvalLibraryConfig = LibraryConfig;

typedef EvalTypeMarshal = BaseTypeMarshal;

class Eval extends Base<
  Eval,
  EvalConfig,
  EvalLibraryConfig,
  EvalTypeMarshal,
  EvalLibrary,
  EvalMarshal
> {
  public function new(config:EvalConfig) {
    super("eval", config);
  }

  public function createLibrary(libConfig:EvalLibraryConfig):EvalLibrary {
    return new EvalLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      // TODO: avoid clashes in the Haxe plugins directory somehow
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/c'), EnsureDirectory));
      ops.push(BOAlways(File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/ml'), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/dune'),
        // TODO: support frameworks
        WriteContent('(data_only_dirs cmxs hx)
(include_subdirs unqualified)
(library
  (name ammer_core_${lib.config.name})
  (libraries haxe)
  (foreign_stubs (language c) (names stubs))
)')
      ));
      ops.push(BOAlways(
        File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/c/stubs.c'),
        WriteContent(lib.lb.done())
      ));
      ops.push(BOAlways(
        File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/ml/plugin.ml'),
        WriteContent(lib.lbml.done())
      ));
      ops.push(BOCwd(
        config.haxeRepoPath,
        [
          // TODO: MSVC support
          BOAlways(File(""), Command("make", ["plugin", 'PLUGIN=ammer_core_${lib.config.name}'])),
        ]
      ));
      ops.push(BODependent(
        // TODO: bytecode
        File('${config.buildPath}/${lib.config.name}.${Sys.systemName()}.cmxs'),
        File('${config.haxeRepoPath}/plugins/ammer_core_${lib.config.name}/cmxs/${Sys.systemName()}/plugin.cmxs'),
        Copy
      ));
    }
    return new BuildProgram(ops);
  }
}

@:allow(ammer.core.plat)
class EvalLibrary extends BaseLibrary<
  EvalLibrary,
  Eval,
  EvalConfig,
  EvalLibraryConfig,
  EvalTypeMarshal,
  EvalMarshal
> {
  var lbInit = new LineBuf();
  var lbml = new LineBuf();
  var staticCallbackIds:Array<String> = [];

  public function new(platform:Eval, config:EvalLibraryConfig) {
    super(platform, config, new EvalMarshal(this));

    lb.ail('#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>

CAMLprim value _ammer_eval_tohaxecopy(value data, value size) {
  CAMLparam2(data, size);
  uint8_t* data_w = (uint8_t*)Int64_val(Field(data, 0));
  uint32_t size_w = Int32_val(Field(size, 0));
  CAMLlocal1(ret);
  ret = caml_alloc_string(size_w);
  ${config.memcpyFunction}(&Byte_u(ret, 0), data_w, size_w);
  CAMLreturn(ret);
}
CAMLprim value _ammer_eval_fromhaxecopy(value data, value size) {
  CAMLparam2(data, size);
  uint8_t* data_w = &Byte_u(data, 0);
  uint32_t size_w = Int32_val(Field(size, 0));
  uint8_t* ret_w = (uint8_t*)${config.mallocFunction}(size_w);
  ${config.memcpyFunction}(ret_w, data_w, size_w);
  CAMLlocal2(ret, tmp);
  ret = caml_alloc(1, 15);
  tmp = caml_copy_int64((int64_t)ret_w);
  Store_field(ret, 0, tmp);
  CAMLreturn(ret);
}

typedef struct { value data; int32_t refcount; } _ammer_haxe_ref;
CAMLprim value _ammer_ref_create(value obj) {
  CAMLparam1(obj);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->data = obj;
  caml_register_global_root(&ref->data);
  ref->refcount = 0;
  CAMLlocal2(ret, tmp);
  ret = caml_alloc(1, 15);
  tmp = caml_copy_int64((int64_t)ref);
  Store_field(ret, 0, tmp);
  CAMLreturn(ret);
}
CAMLprim value _ammer_ref_delete(value vref) {
  CAMLparam1(vref);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)Int64_val(Field(vref, 0));
  caml_remove_global_root(&ref->data);
  ref->data = Val_unit;
  ${config.freeFunction}(ref);
  CAMLreturn(Val_unit);
}
CAMLprim value _ammer_ref_getcount(value vref) {
  CAMLparam1(vref);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)Int64_val(Field(vref, 0));
  CAMLlocal2(ret, tmp);
  ret = caml_alloc(1, 0);
  tmp = caml_copy_int32(ref->refcount);
  Store_field(ret, 0, tmp);
  CAMLreturn(ret);
}
CAMLprim value _ammer_ref_setcount(value vref, value wrc) {
  CAMLparam2(vref, wrc);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)Int64_val(Field(vref, 0));
  ref->refcount = Int32_val(Field(wrc, 0));
  CAMLreturn(Val_unit);
}
CAMLprim value _ammer_ref_getvalue(value vref) {
  CAMLparam1(vref);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)Int64_val(Field(vref, 0));
  CAMLreturn(ref->data);
}

static value _ammer_haxe_scb;
static value _ammer_haxe_decode_i64;
static value _ammer_haxe_encode_i64;
static value _ammer_haxe_decode_string;
static value _ammer_haxe_encode_string;
');

    lbml.ail('
open EvalContext
open EvalDecode
open EvalEncode
open EvalExceptions
open EvalHash
open EvalIntegers
open EvalStdLib
open EvalValue

(* see https://github.com/HaxeFoundation/haxe/pull/10800 *)
let decode_haxe_i64_fix v =
	match v with
	| VInstance vi when is v key_haxe__Int64____Int64 ->
		let high = decode_i32 (vi.ifields.(get_instance_field_index_raise vi.iproto key_high))
		and low = decode_i32 (vi.ifields.(get_instance_field_index_raise vi.iproto key_low)) in
		let high64 = Int64.shift_left (Signed.Int32.to_int64 high) 32
		and low64 = Int64.logand (Signed.Int32.to_int64 low) 0xffffffffL in
		Int64.logor high64 low64
	| _ ->
		unexpected_value v "haxe.Int64"

external _ammer_eval_tohaxecopy : value -> value -> bytes = "_ammer_eval_tohaxecopy"
external _ammer_eval_fromhaxecopy : bytes -> value -> value = "_ammer_eval_fromhaxecopy"

external _ammer_ref_create : value -> value = "_ammer_ref_create"
external _ammer_ref_delete : value -> value = "_ammer_ref_delete"
external _ammer_ref_getcount : value -> value = "_ammer_ref_getcount"
external _ammer_ref_setcount : value -> value -> value = "_ammer_ref_setcount"
external _ammer_ref_getvalue : value -> value = "_ammer_ref_getvalue"

external _ammer_init : value array -> (value -> Int64.t) -> (Int64.t -> value) -> (value -> Extlib_leftovers.UTF8.t) -> (Extlib_leftovers.UTF8.t -> value) -> value = "_ammer_init"
');
  }

  override function finalise(platConfig:EvalConfig):Void {
    var scbInit = [ for (id => cb in staticCallbackIds) {
      macro $p{tdefStaticCallbacks.pack.concat([tdefStaticCallbacks.name])}.$cb;
    } ];
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Any),
        macro {
          var scb:Array<Any> = $a{scbInit};
          var plugin:Any = eval.vm.Context.loadPlugin($v{platform.config.buildPath} + "/" + $v{config.name} + "." + Sys.systemName() + ".cmo");
          ((untyped plugin._ammer_init) : (Array<Any>) -> Void)(scb);
          plugin;
        }
      ),
      access: [APrivate, AStatic],
    });

    lb.ail('
CAMLprim value _ammer_init(value scb, value decode_i64, value encode_i64, value decode_string, value encode_string) {
  CAMLparam1(scb);
  _ammer_haxe_scb = scb;
  caml_register_global_root(&_ammer_haxe_scb);
  _ammer_haxe_decode_i64 = decode_i64;
  caml_register_global_root(&_ammer_haxe_decode_i64);
  _ammer_haxe_encode_i64 = encode_i64;
  caml_register_global_root(&_ammer_haxe_encode_i64);
  _ammer_haxe_decode_string = decode_string;
  caml_register_global_root(&_ammer_haxe_decode_string);
  _ammer_haxe_encode_string = encode_string;
  caml_register_global_root(&_ammer_haxe_encode_string);
  CAMLreturn(Val_unit);
}');
    lbml
      .ail(";; EvalStdLib.StdContext.register [")
      .ail('"_ammer_eval_tohaxecopy", vstatic_function (function | [v1;v2] -> encode_bytes (_ammer_eval_tohaxecopy v1 v2) | _ -> assert false);')
      .ail('"_ammer_eval_fromhaxecopy", vstatic_function (function | [v1;v2] -> _ammer_eval_fromhaxecopy (decode_bytes v1) v2 | _ -> assert false);')
      .ail('"_ammer_ref_create", vstatic_function (function | [v1] -> _ammer_ref_create v1 | _ -> assert false);')
      .ail('"_ammer_ref_delete", vstatic_function (function | [v1] -> _ammer_ref_delete v1 | _ -> assert false);')
      .ail('"_ammer_ref_getcount", vstatic_function (function | [v1] -> _ammer_ref_getcount v1 | _ -> assert false);')
      .ail('"_ammer_ref_setcount", vstatic_function (function | [v1;v2] -> _ammer_ref_setcount v1 v2 | _ -> assert false);')
      .ail('"_ammer_ref_getvalue", vstatic_function (function | [v1] -> _ammer_ref_getvalue v1 | _ -> assert false);')
      .ail('"_ammer_init", vstatic_function (function | [VArray v1] -> _ammer_init (v1.avalues) decode_haxe_i64_fix encode_haxe_i64_direct decode_string encode_string | _ -> assert false);')
      .addBuf(lbInit)
      .ail("];");
    super.finalise(platConfig);
    outputPathRelative = null; // TODO: output path does not really make sense here, but what about .cmxo files?
  }

  public function addNamedFunction(
    name:String,
    ret:EvalTypeMarshal,
    args:Array<EvalTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    if (args.length > 5) {
      lb.ail('CAMLprim value bc_${name}(value *argv, int argn) {')
        .i()
          .ai('return nat_${name}(')
          .mapi(args, (idx, arg) -> 'argv[$idx]', ", ")
          .al(');')
        .d()
        .ail("}");
    }
    lb.ai('CAMLprim value nat_${name}(')
      .mapi(args, (idx, arg) -> 'value _l1_arg_$idx', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(') {')
      .i();
    var pi = 0;
    while (pi < args.length) {
      var sub = [ for (i in pi...Std.int(Math.min(args.length, pi + 5))) i ];
      lb.ail('CAML${pi == 0 ? "" : "x"}param${sub.length}(${sub.map(s -> '_l1_arg_$s').join(", ")});');
      pi += 5;
    }
    if (args.length == 0)
      lb.ail("CAMLparam0();");
    lb.ail("CAMLlocal1(_eval_tmp);");
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
          .ail('CAMLreturn(_l1_return);')
        .ife()
          .ail("CAMLreturn(Val_unit);")
        .ifd()
      .d()
      .ail("}");
    lbml.ai('external $name : ')
      .a(args.length == 0 ? "unit -> " : "")
      .map(args, _ -> "value -> ")
      .a("value =")
      .ifi(args.length > 5)
        .a(' "bc_$name"')
      .ifd()
      .al(' "nat_$name"');
    var evalCall = new LineBuf()
      .a('$name ')
      .mapi(args, (idx, arg) -> 'arg$idx', " ")
      .a(args.length == 0 ? "()" : "")
      .done();
    lbInit.ail('"${name}", vstatic_function (function')
      .ai('| [')
      .mapi(args, (idx, arg) -> 'arg$idx', "; ")
      .a('] -> ')
      .al(evalCall)
      .al('| _ -> vbool true);');
    var funcType = TFunction(args.map(arg -> arg.haxeType), ret.haxeType);
    // TODO: position?
    return macro ((untyped $e{fieldExpr("_ammer_native")}.$name) : $funcType);
  }

  // CAMLlocal within scopes (`do { ... } while (0);` as in other platforms)
  // might be problematic, use a counter instead
  var closureScope = 0;

  function baseCall(
    lb:LineBuf,
    scope:String,
    ret:EvalTypeMarshal,
    args:Array<EvalTypeMarshal>,
    outputExpr:String,
    argExprs:Array<String>
  ):Void {
    lb
      // TODO: what about VFieldClosure ? pass an extra decode function?
      .ail('${scope}_l1_fn = Field(${scope}_l1_fn, 0);') // VFunction of vfunc * bool
      .lmapi(args, (idx, arg) -> '${arg.l2Type} ${scope}_l2_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l3l2(argExprs[idx], '${scope}_l2_arg_$idx'))
      .lmapi(args, (idx, arg) -> 'CAMLlocal1(${scope}_l1_arg_${idx});')
      .lmapi(args, (idx, arg) -> arg.l2l1('${scope}_l2_arg_$idx', '${scope}_l1_arg_$idx'))
      // args are a linked list (`value list`)
      .ail('CAMLlocal1(${scope}_l1_arg_${args.length}_cell);
${scope}_l1_arg_${args.length}_cell = Val_int(0);')
      .lmapi(args, (idx, arg) -> 'CAMLlocal1(${scope}_l1_arg_${idx}_cell);
${scope}_l1_arg_${idx}_cell = caml_alloc(2, 0);
Store_field(${scope}_l1_arg_${idx}_cell, 0, ${scope}_l1_arg_${idx});')
      .lmapi(args, (idx, arg) -> 'Store_field(${scope}_l1_arg_${idx}_cell, 1, ${scope}_l1_arg_${idx + 1}_cell);')

      .ifi(ret.mangled != "v")
        .ail('${ret.l1Type} ${scope}_l1_output;')
        .ail('${scope}_l1_output = caml_callback(${scope}_l1_fn, ${scope}_l1_arg_0_cell);')
        .ail('${ret.l2Type} ${scope}_l2_output;')
        .ail(ret.l1l2('${scope}_l1_output', '${scope}_l2_output'))
        .ail(ret.l2l3('${scope}_l2_output', outputExpr))
      .ife()
        .ail('caml_callback(${scope}_l1_fn, ${scope}_l1_arg_0_cell);')
      .ifd();
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<EvalTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    var scope = '_cl${closureScope++}';
    return new LineBuf()
      .ail('${clType.type.l2Type} ${scope}_l2_fn;')
      .ail(clType.type.l3l2(fn, '${scope}_l2_fn'))
      .ail('CAMLlocal1(${scope}_l1_fn_ref);')
      .ail(clType.type.l2l1('${scope}_l2_fn', '${scope}_l1_fn_ref'))
      .ail('CAMLlocal1(${scope}_l1_fn);')
      .ail('${scope}_l1_fn = ((_ammer_haxe_ref*)Int64_val(Field(${scope}_l1_fn_ref, 0)))->data;')
      .apply(baseCall.bind(_, scope, clType.ret, clType.args, outputExpr, args))
      .done();
  }

  public function staticCall(
    ret:EvalTypeMarshal,
    args:Array<EvalTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    var scope = '_cl${closureScope++}';
    var name = baseStaticCall(ret, args, code);
    var scbId = staticCallbackIds.length;
    staticCallbackIds.push(name);
    return new LineBuf()
      .ail('CAMLlocal1(${scope}_l1_fn);')
      .ail('${scope}_l1_fn = Field(_ammer_haxe_scb, ${scbId});')
      .apply(baseCall.bind(_, scope, ret, args, outputExpr, argExprs))
      .done();
  }

  public function addCallback(
    ret:EvalTypeMarshal,
    args:Array<EvalTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail("CAMLparam0();")
        .ail("CAMLlocal1(_eval_tmp);")
        .ifi(ret.mangled != "v")
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('CAMLreturnT(${ret.l3Type}, ${config.returnIdent});')
        .ife()
          .ail(code)
          .ail("CAMLreturn0;")
        .ifd()
      .d()
      .al("}");
    return name;
  }
}

@:allow(ammer.core.plat)
class EvalMarshal extends BaseMarshal<
  EvalMarshal,
  Eval,
  EvalConfig,
  EvalLibraryConfig,
  EvalLibrary,
  EvalTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):EvalTypeMarshal {
    return {
      haxeType:  over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "value", an OCaml tagged pointer
      l1Type:   "value",
      l2Type:    over.l2Type    != null ? over.l2Type    : base.l2Type,
      l3Type:    over.l3Type    != null ? over.l3Type    : base.l3Type,
      mangled:   over.mangled   != null ? over.mangled   : base.mangled,
      l1l2:      over.l1l2      != null ? over.l1l2      : base.l1l2,
      l2l3:      over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2l1:      over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over.arrayType != null ? over.arrayType : base.arrayType,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid(), {
    l1l2: BaseMarshal.MARSHAL_NOOP2,
    l2l1: (l2, l1) -> '$l1 = Val_unit;',
  });
  public function void():EvalTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
    l1l2: (l1, l2) -> '$l2 = (Int_val($l1) == 1);',
    l2l1: (l2, l1) -> '$l1 = Val_int($l2 ? 1 : 2);',
  });
  public function bool():EvalTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
    l1l2: (l1, l2) -> '$l2 = Int32_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 0);
_eval_tmp = caml_copy_int32($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  public function uint8():EvalTypeMarshal return MARSHAL_UINT8;
  public function int8():EvalTypeMarshal return MARSHAL_INT8;
  public function uint16():EvalTypeMarshal return MARSHAL_UINT16;
  public function int16():EvalTypeMarshal return MARSHAL_INT16;
  public function uint32():EvalTypeMarshal return MARSHAL_UINT32;
  public function int32():EvalTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    l1l2: (l1, l2) -> '_eval_tmp = caml_callback(_ammer_haxe_decode_i64, $l1);
$l2 = Int64_val(_eval_tmp);',
    l2l1: (l2, l1) -> '_eval_tmp = caml_copy_int64($l2);
$l1 = caml_callback(_ammer_haxe_encode_i64, _eval_tmp);',
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshal.baseInt64(), {
    l1l2: (l1, l2) -> '_eval_tmp = caml_callback(_ammer_haxe_decode_i64, $l1);
$l2 = Int64_val(_eval_tmp);',
    l2l1: (l2, l1) -> '_eval_tmp = caml_copy_int64($l2);
$l1 = caml_callback(_ammer_haxe_encode_i64, _eval_tmp);',
  });
  public function uint64():EvalTypeMarshal return MARSHAL_UINT64;
  public function int64():EvalTypeMarshal return MARSHAL_INT64;

  public function enumInt(name:String, type:EvalTypeMarshal):EvalTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {});

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat64As32(), {
    l1l2: (l1, l2) -> '$l2 = Tag_val($l1) == 0 ? ((double)Int32_val(Field($l1, 0))) : Double_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 1);
_eval_tmp = caml_copy_double($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    l1l2: (l1, l2) -> '$l2 = Tag_val($l1) == 0 ? ((double)Int32_val(Field($l1, 0))) : Double_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 1);
_eval_tmp = caml_copy_double($l2);
Store_field($l1, 0, _eval_tmp);',
  });
  public function float32():EvalTypeMarshal return MARSHAL_FLOAT32;
  public function float64():EvalTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    l1l2: (l1, l2) -> '_eval_tmp = caml_callback(_ammer_haxe_decode_string, $l1);
$l2 = String_val(_eval_tmp);',
    l2l1: (l2, l1) -> '_eval_tmp = caml_copy_string($l2);
$l1 = caml_callback(_ammer_haxe_encode_string, _eval_tmp);',
  });
  public function string():EvalTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : eval.integers.UInt64),
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)Int64_val(Field($l1, 0));',
    l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 15);
_eval_tmp = caml_copy_int64((uint64_t)$l2);
Store_field($l1, 0, _eval_tmp);',
  });
  function bytesInternalType():EvalTypeMarshal return MARSHAL_BYTES;
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
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : eval.integers.UInt64);
        var _size = ($size : Int);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_eval_tohaxecopy) : (eval.integers.UInt64, Int) -> haxe.io.Bytes)(
          _self,
          _size
        );
        (_ret : haxe.io.Bytes);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_eval_fromhaxecopy) : (haxe.io.Bytes, Int) -> eval.integers.UInt64)(
          _bytes,
          _bytes.length
        );
        (_ret : eval.integers.UInt64);
      },

      toHaxeRef: null,
      fromHaxeRef: null,
    };
  }

  function opaqueInternal(name:String):EvalTypeMarshal {
    var mname = Mangle.identifier(name);
    return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
      haxeType: (macro : eval.integers.UInt64),
      l1l2: (l1, l2) -> '$l2 = ($name)Int64_val(Field($l1, 0));',
      l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 15);
_eval_tmp = caml_copy_int64((uint64_t)$l2);
Store_field($l1, 0, _eval_tmp);',
    });
  }

  function structPtrDerefInternal(name:String):EvalTypeMarshal {
    var mname = Mangle.identifier('$name*');
    return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
      haxeType: (macro : eval.integers.UInt64),
      l1l2: (l1, l2) -> '$l2 = ($name*)Int64_val(Field($l1, 0));',
      l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 15);
_eval_tmp = caml_copy_int64((uint64_t)$l2);
Store_field($l1, 0, _eval_tmp);',
    });
  }

  function arrayPtrInternalType(element:EvalTypeMarshal):EvalTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    haxeType: (macro : eval.integers.UInt64),
      l1l2: (l1, l2) -> '$l2 = (${element.l2Type}*)Int64_val(Field($l1, 0));',
      l2l1: (l2, l1) -> '$l1 = caml_alloc(1, 15);
_eval_tmp = caml_copy_int64((uint64_t)$l2);
Store_field($l1, 0, _eval_tmp);',
  });

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<EvalTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : eval.integers.UInt64),
      macro eval.integers.UInt64.ZERO,
      macro ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_ref_getvalue) : (eval.integers.UInt64) -> $haxeType)(handle),
      macro ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_ref_getcount) : (eval.integers.UInt64) -> Int)(handle),
      rc -> macro ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_ref_setcount) : (eval.integers.UInt64, Int) -> Void)(handle, $rc),
      value -> macro ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_ref_create) : ($haxeType) -> eval.integers.UInt64)($value),
      macro ((untyped $e{library.fieldExpr("_ammer_native")}._ammer_ref_delete) : (eval.integers.UInt64) -> Void)(handle),
      null,
      // comparison of eval.integers.UInt64 values does not work properly, so
      // a null value (VNull) is used to indicate a null pointer
      handle -> macro $handle == null || $handle == eval.integers.UInt64.ZERO
    );
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):EvalTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: (macro : eval.integers.UInt64),
    l1l2: (l1, l2) -> '$l2 = (_ammer_haxe_ref*)Int64_val(Field($l1, 0));',
    l2l1: (l2, l1) -> 'if ($l2 == NULL) {
  $l1 = Val_int(0);
} else {
  $l1 = caml_alloc(1, 15);
  _eval_tmp = caml_copy_int64((uint64_t)$l2);
  Store_field($l1, 0, _eval_tmp);
}',
  });

  public function new(library:EvalLibrary) {
    super(library);
  }
}

#end
