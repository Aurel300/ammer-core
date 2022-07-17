package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

@:structInit
class NodejsConfig extends BaseConfig {
  public var nodeGypBinary:String = "node-gyp";
  // TODO: node-gyp config for electron etc?
}

typedef NodejsLibraryConfig = LibraryConfig;

typedef NodejsTypeMarshal = BaseTypeMarshal;

class Nodejs extends Base<
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsTypeMarshal,
  NodejsLibrary,
  NodejsMarshalSet
> {
  public function new(config:NodejsConfig) {
    super("nodejs", config);
  }

  public function finalise():BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.abi.extension();
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/binding.gyp'),
        // TODO: more configuration?
        // TODO: stringify as JSON
        WriteContent('{"targets": [{
  "target_name": "binding",
  "sources": ["lib.nodejs.$ext"],
  "include_dirs": [${lib.config.includePaths.map(p -> '"$p"').join(",")}],
  "link_settings": {
    "library_dirs": [${lib.config.libraryPaths.map(p -> '"$p"').join(",")}],
    "libraries": [${lib.config.linkNames.map(p -> '"-l$p"').join(",")}],
  },
}]}')
      ));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.nodejs.$ext'),
        WriteContent(lib.lb.done())
      ));
      ops.push(BOCwd(
        '${config.buildPath}/${lib.config.name}',
        [
          BOAlways(File(""), Command(config.nodeGypBinary, ["configure"])),
          BOAlways(File(""), Command(config.nodeGypBinary, ["build"])),
        ]
      ));
      ops.push(BODependent(
        File('${config.outputPath}/${lib.config.name}.node'),
        File('${config.buildPath}/${lib.config.name}/build/Release/binding.node'),
        Copy
      ));
    }
    return new BuildProgram(ops);
  }
}

class NodejsLibrary extends BaseLibrary<
  NodejsLibrary,
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsTypeMarshal,
  NodejsMarshalSet
> {
  var lbInit = new LineBuf();
  var exportCount = 0;

  public function new(config:NodejsLibraryConfig) {
    super(config, new NodejsMarshalSet(this));
    tdef.isExtern = true;
    tdef.meta.push({
      pos: config.pos,
      params: [macro $v{"./" + config.name + ".node"}],
      name: ":jsRequire",
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_tobytescopy",
      kind: TypeUtils.ffunCt((macro : (Dynamic, Int) -> js.lib.ArrayBuffer)),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_frombytescopy",
      kind: TypeUtils.ffunCt((macro : (js.lib.ArrayBuffer) -> Dynamic)),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_tobytesref",
      kind: TypeUtils.ffunCt((macro : (Dynamic, Int) -> js.lib.ArrayBuffer)),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_frombytesref",
      kind: TypeUtils.ffunCt((macro : (js.lib.ArrayBuffer) -> Dynamic)),
      access: [APrivate, AStatic],
    });
    lb.ail("#define NAPI_VERSION 3");
    lb.ail("#include <node_api.h>");
    lb.ail("#define NAPI_CALL_ENV(_nodejs_env, call, dref)                    \\
  do {                                                            \\
    napi_status status = (call);                                  \\
    if (status != napi_ok) {                                      \\
      const napi_extended_error_info* error_info = NULL;          \\
      napi_get_last_error_info(_nodejs_env, &error_info);         \\
      const char* err_message = error_info->error_message;        \\
      bool is_pending;                                            \\
      napi_is_exception_pending(_nodejs_env, &is_pending);        \\
      if (!is_pending) {                                          \\
        const char* message = (err_message == NULL)               \\
            ? \"empty error message\"                               \\
            : err_message;                                        \\
        napi_throw_error(_nodejs_env, NULL, message);             \\
        return dref;                                              \\
      }                                                           \\
    }                                                             \\
  } while(0)");
    lb.ail("#define NAPI_CALL(call) NAPI_CALL_ENV(_nodejs_env, call, 0)");
    lb.ail("#define NAPI_CALL_V(call) NAPI_CALL_ENV(_nodejs_env, call,)");
    lb.ail("static size_t _ammer_ctr = 0;"); // TODO: internalPrefix
    boilerplate(
      "napi_env",
      "void*",
      "napi_ref ref;",
      "",
      'NAPI_CALL_ENV(${config.internalPrefix}registry.ctx, napi_delete_reference(${config.internalPrefix}registry.ctx, curr->ref),);'
    );
  }

  override function finalise(platConfig:NodejsConfig):Void {
    lb.ail('#define NAPI_CALL_I NAPI_CALL
static napi_value _ammer_nodejs_tobytescopy(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 2;
  napi_value _nodejs_argv[2];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  uint32_t size;
  NAPI_CALL_I(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&data));
  NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, _nodejs_argv[1], &size));
  uint8_t* data_res;
  napi_value res;
  NAPI_CALL_I(napi_create_arraybuffer(_nodejs_env, size, (void**)&data_res, &res));
  ${config.memcpyFunction}(data_res, data, size);
  return res;
}
static napi_value _ammer_nodejs_frombytescopy(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  size_t size;
  NAPI_CALL_I(napi_get_arraybuffer_info(_nodejs_env, _nodejs_argv[0], (void**)&data, &size));
  uint8_t* data_res = (uint8_t*)${config.mallocFunction}(size);
  ${config.memcpyFunction}(data_res, data, size);
  napi_value res;
  NAPI_CALL_I(napi_create_object(_nodejs_env, &res));
  NAPI_CALL_I(napi_wrap(_nodejs_env, res, (void*)data_res, NULL, NULL, NULL));
  return res;
}
static napi_value _ammer_nodejs_tobytesref(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 2;
  napi_value _nodejs_argv[2];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  uint32_t size;
  NAPI_CALL_I(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&data));
  NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, _nodejs_argv[1], &size));
  napi_value res;
  // TODO: NULL passed to finalise, pass a dummy method instead?
  NAPI_CALL_I(napi_create_external_arraybuffer(_nodejs_env, (void*)data, size, NULL, NULL, &res));
  return res;
}
static napi_value _ammer_nodejs_frombytesref(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  // TODO: should this create the reference?
  /*
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  size_t size;
  NAPI_CALL_I(napi_get_arraybuffer_info(_nodejs_env, _nodejs_argv[0], (void**)&data, &size));
  napi_value res_ptr;
  NAPI_CALL_I(napi_create_object(_nodejs_env, &res_ptr));
  NAPI_CALL_I(napi_wrap(_nodejs_env, res_ptr, (void*)data, NULL, NULL, NULL));
  napi_ref res_ref;
  NAPI_CALL_I(napi_create_reference(_nodejs_env, _nodejs_argv[0], 1, &res_ref));
  napi_value res;
  NAPI_CALL_I(napi_create_array_with_length(_nodejs_env, 2, &res));
  NAPI_CALL_I(napi_set_element(_nodejs_env, res, 0, ...));
  NAPI_CALL_I(napi_set_element(_nodejs_env, res, 1, ...));
  return res;
  */
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  size_t size;
  NAPI_CALL_I(napi_get_arraybuffer_info(_nodejs_env, _nodejs_argv[0], (void**)&data, &size));
  napi_value res;
  NAPI_CALL_I(napi_create_object(_nodejs_env, &res));
  NAPI_CALL_I(napi_wrap(_nodejs_env, res, (void*)data, NULL, NULL, NULL));
  return res;
}
#undef NAPI_CALL_I
NAPI_MODULE_INIT() {
  napi_property_descriptor _init_wrap[] = {
').addBuf(lbInit).ail('
    {"_ammer_nodejs_tobytescopy", NULL, _ammer_nodejs_tobytescopy, NULL, NULL, NULL, 0, NULL},
    {"_ammer_nodejs_frombytescopy", NULL, _ammer_nodejs_frombytescopy, NULL, NULL, NULL, 0, NULL},
    {"_ammer_nodejs_tobytesref", NULL, _ammer_nodejs_tobytesref, NULL, NULL, NULL, 0, NULL},
    {"_ammer_nodejs_frombytesref", NULL, _ammer_nodejs_frombytesref, NULL, NULL, NULL, 0, NULL},
  };
  if (napi_define_properties(env, exports, ${exportCount + 4}, _init_wrap) != napi_ok) return NULL;
  ${config.internalPrefix}registry.ctx = env;
  return exports;
}');
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ail('static ${ret.l1Type} ${name}(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {')
      .i()
        .ail('#define NAPI_CALL_I NAPI_CALL')
        .ail('size_t _nodejs_argc = ${args.length};')
        .ail('napi_value _nodejs_argv[${args.length}];')
        .ail('NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));');
    baseAddNamedFunction(
      args,
      args.mapi((idx, arg) -> '_nodejs_argv[$idx]'),
      ret,
      "_l1_return",
      code,
      lb,
      options
    );
    lb
        .ifi(ret.mangled == "v")
          .ail('${ret.l1Type} _l1_return;')
          .ail("NAPI_CALL_I(napi_get_undefined(_nodejs_env, &_l1_return));")
        .ifd()
        .ail("return _l1_return;")
        .ail("#undef NAPI_CALL_I")
      .d()
      .ail("}");
    lbInit.ail('{"${name}", NULL, ${name}, NULL, NULL, NULL, 0, NULL},');
    exportCount++;
    tdef.fields.push({
      pos: options.pos,
      name: name,
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType),
      access: [APublic, AStatic],
    });
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<NodejsTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    // TODO: what about rebound "this"?
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
        .ail('${clType.ret.l1Type} _l1_output;')
        .ai('NAPI_CALL_I(napi_call_function(_nodejs_env, _l1_fn, _l1_fn, ${args.length}, (napi_value[]){')
        .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
        .al("}, &_l1_output));")
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
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    var napiCall = (ret == NodejsMarshalSet.MARSHAL_VOID ? "NAPI_CALL_V" : "NAPI_CALL");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail('#define NAPI_CALL_I $napiCall')
        .ail('napi_env _nodejs_env = ${config.internalPrefix}registry.ctx;')
        .ail("napi_handle_scope _nodejs_scope;")
        .ail('$napiCall(napi_open_handle_scope(_nodejs_env, &_nodejs_scope));')
        .ifi(ret.mangled != "v")
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('$napiCall(napi_close_handle_scope(_nodejs_env, _nodejs_scope));')
          .ail('return ${config.returnIdent};')
        .ife()
          .ail(code)
          .ail('$napiCall(napi_close_handle_scope(_nodejs_env, _nodejs_scope));')
        .ifd()
        .ail("#undef NAPI_CALL_I")
      .d()
      .al("}");
    return name;
  }
}

@:allow(ammer.core.plat.Nodejs)
class NodejsMarshalSet extends BaseMarshalSet<
  NodejsMarshalSet,
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsLibrary,
  NodejsTypeMarshal
> {
  // TODO: ${config.internalPrefix}
  // TODO: this already roots
  static final MARSHAL_REGISTRY_GET_NODE = (l1:String, l2:String)
    -> '$l2 = _ammer_core_registry_get((void*)_ammer_ctr++);
NAPI_CALL_I(napi_create_reference(_nodejs_env, $l1, 1, &$l2->ref));';
  static final MARSHAL_REGISTRY_REF = (l2:String)
    -> '_ammer_core_registry_incref($l2);';
  static final MARSHAL_REGISTRY_UNREF = (l2:String)
    -> '_ammer_core_registry_decref($l2);';
  static final MARSHAL_REGISTRY_GET_KEY = (l2:String, l1:String) // TODO: target type cast
    -> 'NAPI_CALL_I(napi_get_reference_value(_nodejs_env, $l2->ref, &$l1));';

  static function baseExtend(
    base:BaseTypeMarshal,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):NodejsTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "napi_value", a Node.js tagged pointer (or boxed NaN)
      l1Type:   "napi_value",
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

  static final MARSHAL_VOID = baseExtend(BaseMarshalSet.baseVoid());
  public function void():NodejsTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshalSet.baseBool(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_bool(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_get_boolean(_nodejs_env, $l2, &$l1));',
  });
  public function bool():NodejsTypeMarshal return MARSHAL_BOOL;

  // the API expects a pointer to int32_t, providing a pointer to a smaller
  // type can lead to stack corruption
  static final MARSHAL_CAST_FROM_INT32 = (type:String, signed:Bool)
    -> (l1:String, l2:String) -> 'do {
  ${signed ? "" : "u"}int32_t _nodejs_tmp;
  NAPI_CALL_I(napi_get_value_${signed ? "" : "u"}int32(_nodejs_env, $l1, &_nodejs_tmp));
  $l2 = ($type)_nodejs_tmp;
} while (0);';
  static final MARSHAL_CAST_TO_INT32 = (signed:Bool)
    -> (l2:String, l1:String) -> 'do {
  ${signed ? "" : "u"}int32_t _nodejs_tmp = $l2;
  NAPI_CALL_I(napi_create_${signed ? "" : "u"}int32(_nodejs_env, _nodejs_tmp, &$l1));
} while (0);';

  static final MARSHAL_UINT8 = baseExtend(BaseMarshalSet.baseUint8(), {
    l1l2: MARSHAL_CAST_FROM_INT32("uint8_t", false),
    l2l1: MARSHAL_CAST_TO_INT32(false),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshalSet.baseInt8(), {
    l1l2: MARSHAL_CAST_FROM_INT32("int8_t", true),
    l2l1: MARSHAL_CAST_TO_INT32(true),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshalSet.baseUint16(), {
    l1l2: MARSHAL_CAST_FROM_INT32("uint16_t", false),
    l2l1: MARSHAL_CAST_TO_INT32(false),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshalSet.baseInt16(), {
    l1l2: MARSHAL_CAST_FROM_INT32("int16_t", true),
    l2l1: MARSHAL_CAST_TO_INT32(true),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshalSet.baseUint32(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2, &$l1));',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshalSet.baseInt32(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_int32(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2, &$l1));',
  });
  public function uint8():NodejsTypeMarshal return MARSHAL_UINT8;
  public function int8():NodejsTypeMarshal return MARSHAL_INT8;
  public function uint16():NodejsTypeMarshal return MARSHAL_UINT16;
  public function int16():NodejsTypeMarshal return MARSHAL_INT16;
  public function uint32():NodejsTypeMarshal return MARSHAL_UINT32;
  public function int32():NodejsTypeMarshal return MARSHAL_INT32;

  // TODO: a single _nodejs_tmp? per-function?
  // TODO: very verbose: wrap into macros?
  static final MARSHAL_UINT64 = baseExtend(BaseMarshalSet.baseUint64(), {
    l1l2: (l1, l2) -> 'do {
  napi_value _nodejs_tmp;
  uint32_t _nodejs_high;
  uint32_t _nodejs_low;
  NAPI_CALL_I(napi_get_named_property(_nodejs_env, $l1, "high", &_nodejs_tmp));
  NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, _nodejs_tmp, &_nodejs_high));
  NAPI_CALL_I(napi_get_named_property(_nodejs_env, $l1, "low", &_nodejs_tmp));
  NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, _nodejs_tmp, &_nodejs_low));
  $l2 = ((uint64_t)_nodejs_high << 32) | (uint32_t)_nodejs_low;
} while (0);',
    l2l1: (l2, l1) -> 'do {
  NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  napi_value _nodejs_tmp;
  NAPI_CALL_I(napi_create_int32(_nodejs_env, ((uint64_t)$l2 >> 32) & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "high", _nodejs_tmp));
  NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2 & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "low", _nodejs_tmp));
} while (0);',
  });
  static final MARSHAL_INT64  = baseExtend(BaseMarshalSet.baseInt64(), {
    l1l2: (l1, l2) -> 'do {
  napi_value _nodejs_tmp;
  NAPI_CALL_I(napi_get_named_property(_nodejs_env, $l1, "high", &_nodejs_tmp));
  int32_t _nodejs_high;
  uint32_t _nodejs_low;
  NAPI_CALL_I(napi_get_value_int32(_nodejs_env, _nodejs_tmp, &_nodejs_high));
  NAPI_CALL_I(napi_get_named_property(_nodejs_env, $l1, "low", &_nodejs_tmp));
  NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, _nodejs_tmp, &_nodejs_low));
  $l2 = ((int64_t)_nodejs_high << 32) | (uint32_t)_nodejs_low;
} while (0);',
    l2l1: (l2, l1) -> 'do {
  NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  napi_value _nodejs_tmp;
  NAPI_CALL_I(napi_create_int32(_nodejs_env, ((uint64_t)$l2 >> 32) & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "high", _nodejs_tmp));
  NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2 & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "low", _nodejs_tmp));
} while (0);',
  });
  public function uint64():NodejsTypeMarshal return MARSHAL_UINT64;
  public function int64():NodejsTypeMarshal return MARSHAL_INT64;

  // static final MARSHAL_FLOAT32 = baseExtend(BaseMarshalSet.baseFloat32(), {
  //   l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_double(_nodejs_env, $l1, &$l2));',
  //   l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_double(_nodejs_env, $l2, &$l1));',
  // });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshalSet.baseFloat64(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_double(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_double(_nodejs_env, $l2, &$l1));',
  });
  public function float32():NodejsTypeMarshal throw "!";
  public function float64():NodejsTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshalSet.baseString(), {
    // TODO: mallocFunction
    // TODO: check malloc != null
    l1l2: (l1, l2) -> 'do {
  size_t _nodejs_tmp;
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, NULL, 0, &_nodejs_tmp));
  $l2 = (const char *)malloc(_nodejs_tmp + 1);
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, (char*)$l2, _nodejs_tmp + 1, &_nodejs_tmp));
} while (0);',
    // l2ref: BaseMarshalSet.MARSHAL_NOOP1, // TODO: ref?
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_string_utf8(_nodejs_env, $l2, NAPI_AUTO_LENGTH, &$l1));',
  });
  public function string():NodejsTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshalSet.baseBytesInternal(), {
    haxeType: (macro : Dynamic),
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  });
  function bytesInternalType():NodejsTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  } {
    var pathBytesRef = baseBytesRef(
      (macro : Int), macro 0,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toBytesCopy: (self, size) -> macro {
        var _self:Dynamic = $self;
        var _size:Int = $size;
        var _res:js.lib.ArrayBuffer = (@:privateAccess $e{library.fieldExpr("_ammer_nodejs_tobytescopy")})(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $e{library.fieldExpr("_ammer_nodejs_frombytescopy")})(_bytes.getData());
      },

      toBytesRef: (self, size) -> macro {
        var _self:Dynamic = $self;
        var _size:Int = $size;
        var _res:js.lib.ArrayBuffer = (@:privateAccess $e{library.fieldExpr("_ammer_nodejs_tobytesref")})(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesRef: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        var _ptr:Dynamic = (@:privateAccess $e{library.fieldExpr("_ammer_nodejs_frombytesref")})(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaqueInternal(name:String):MarshalOpaque<NodejsTypeMarshal> return {
    type: baseExtend(BaseMarshalSet.baseOpaquePtrInternal(name), {
      haxeType: (macro : Dynamic),
      l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
      l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
    }),
    typeDeref: baseExtend(BaseMarshalSet.baseOpaqueDirectInternal(name), {
      haxeType: (macro : Dynamic),
      l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
      l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
    }),
  };

  function arrayPtrInternalType(element:NodejsTypeMarshal):NodejsTypeMarshal return baseExtend(BaseMarshalSet.baseArrayPtrInternal(element), {
    haxeType: (macro : Dynamic),
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  });

  function haxePtrInternal(haxeType:ComplexType):NodejsTypeMarshal return baseExtend(BaseMarshalSet.baseHaxePtrInternal(haxeType), {
    haxeType: haxeType,
    l2Type: '${library.config.internalPrefix}registry_node*',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  });

  public function new(library:NodejsLibrary) {
    super(library);
  }
}

#end
