package ammer.core.plat;

#if macro

@:structInit
class NodejsConfig extends BaseConfig {
  public var nodeGypBinary:String = "node-gyp";
  // TODO: node-gyp config for electron etc?
}

typedef NodejsLibraryConfig = LibraryConfig;

typedef NodejsTypeMarshal = BaseTypeMarshal;

class Nodejs extends Base<
  Nodejs,
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsTypeMarshal,
  NodejsLibrary,
  NodejsMarshal
> {
  public function new(config:NodejsConfig) {
    super("nodejs", config);
  }

  public function createLibrary(libConfig:NodejsLibraryConfig):NodejsLibrary {
    return new NodejsLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.language.extension();
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
    "libraries": [${lib.config.linkNames.map(p -> '"-l$p"').concat(lib.config.frameworks.map(f -> '"$f.framework"')).join(",")}],
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
        File('${config.outputPath}/${lib.outputPathRelative}'),
        File('${config.buildPath}/${lib.config.name}/build/Release/binding.node'),
        Copy
      ));
    }
    return new BuildProgram(ops);
  }
}

@:allow(ammer.core.plat)
class NodejsLibrary extends BaseLibrary<
  NodejsLibrary,
  Nodejs,
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsTypeMarshal,
  NodejsMarshal
> {
  var tdefExtern:TypeDefinition;
  var tdefExternExpr:Expr;
  var lbInit = new LineBuf();
  var exportCount = 0;
  var nativeCount = 0;
  var staticCallbackIds:Array<String> = [];

  function pushNative(name:String, signature:ComplexType, pos:Position):Void {
    nativeCount++;
    tdefExtern.fields.push({
      pos: pos,
      name: name,
      kind: TypeUtils.ffunCt(signature),
      access: [APrivate, AStatic],
    });
  }

  public function new(platform:Nodejs, config:NodejsLibraryConfig) {
    super(platform, config, new NodejsMarshal(this));

    tdefExtern = typeDefCreate();
    tdefExtern.name += "_Native";
    tdefExtern.isExtern = true;
    tdefExtern.meta.push({
      pos: config.pos,
      params: [macro $v{"./" + config.name + ".node"}],
      name: ":jsRequire",
    });

    pushNative("_ammer_nodejs_tohaxecopy", (macro : (Dynamic, Int) -> js.lib.ArrayBuffer), config.pos);
    pushNative("_ammer_nodejs_fromhaxecopy", (macro : (js.lib.ArrayBuffer) -> Dynamic), config.pos);
    pushNative("_ammer_nodejs_tohaxeref", (macro : (Dynamic, Int) -> js.lib.ArrayBuffer), config.pos);
    pushNative("_ammer_nodejs_fromhaxeref", (macro : (js.lib.ArrayBuffer) -> Dynamic), config.pos);

    pushNative("_ammer_ref_create",   (macro : (Dynamic) -> Dynamic), config.pos);
    pushNative("_ammer_ref_delete",   (macro : (Dynamic) -> Void), config.pos);
    pushNative("_ammer_ref_getcount", (macro : (Dynamic) -> Int), config.pos);
    pushNative("_ammer_ref_setcount", (macro : (Dynamic, Int) -> Void), config.pos);
    pushNative("_ammer_ref_getvalue", (macro : (Dynamic) -> Dynamic), config.pos);

    pushNative("_ammer_init", (macro : (Array<Any>) -> Void), config.pos);

    tdefExternExpr = macro $p{config.typeDefPack.concat([config.typeDefName + "_Native"])};
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
    lb.ail('
napi_env _ammer_nodejs_env; // TODO: multple threads?
typedef struct { napi_ref value; int32_t refcount; } _ammer_haxe_ref;
static napi_value _ammer_ref_create(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  NAPI_CALL(napi_create_reference(_nodejs_env, _nodejs_argv[0], 1, &ref->value));
  ref->refcount = 0;
  napi_value res;
  NAPI_CALL(napi_create_object(_nodejs_env, &res));
  NAPI_CALL(napi_wrap(_nodejs_env, res, (void*)ref, NULL, NULL, NULL));
  return res;
}
static napi_value _ammer_ref_delete(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  _ammer_haxe_ref* ref;
  NAPI_CALL(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&ref));
  NAPI_CALL(napi_delete_reference(_nodejs_env, ref->value));
  ref->value = NULL;
  ${config.freeFunction}(ref);
  napi_value res;
  NAPI_CALL(napi_get_undefined(_nodejs_env, &res));
  return res;
}
static napi_value _ammer_ref_getcount(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  _ammer_haxe_ref* ref;
  NAPI_CALL(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&ref));
  napi_value res;
  NAPI_CALL(napi_create_uint32(_nodejs_env, ref->refcount, &res));
  return res;
}
static napi_value _ammer_ref_setcount(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 2;
  napi_value _nodejs_argv[2];
  NAPI_CALL(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  _ammer_haxe_ref* ref;
  NAPI_CALL(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&ref));
  int32_t rc;
  NAPI_CALL(napi_get_value_int32(_nodejs_env, _nodejs_argv[1], &rc));
  ref->refcount = rc;
  napi_value res;
  NAPI_CALL(napi_get_undefined(_nodejs_env, &res));
  return res;
}
static napi_value _ammer_ref_getvalue(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  _ammer_haxe_ref* ref;
  NAPI_CALL(napi_unwrap(_nodejs_env, _nodejs_argv[0], (void**)&ref));
  napi_value res;
  NAPI_CALL(napi_get_reference_value(_nodejs_env, ref->value, &res));
  return res;
}
napi_ref _ammer_haxe_scb;
');
  }

  override function finalise(platConfig:NodejsConfig):Void {
    var scbInit = [ for (id => cb in staticCallbackIds) {
      macro $p{tdefStaticCallbacks.pack.concat([tdefStaticCallbacks.name])}.$cb;
    } ];
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          var scb:Array<Any> = $a{scbInit};
          (@:privateAccess $tdefExternExpr._ammer_init)(scb);
          0;
        }
      ),
      access: [APrivate, AStatic],
    });

    lb.ail('#define NAPI_CALL_I NAPI_CALL
static napi_value _ammer_nodejs_tohaxecopy(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
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
static napi_value _ammer_nodejs_fromhaxecopy(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
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
static napi_value _ammer_nodejs_tohaxeref(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
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
static napi_value _ammer_nodejs_fromhaxeref(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
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
static napi_value _ammer_init(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  NAPI_CALL_I(napi_create_reference(_nodejs_env, _nodejs_argv[0], 1, &_ammer_haxe_scb));
  napi_value res;
  NAPI_CALL_I(napi_get_undefined(_nodejs_env, &res));
  return res;
}
#undef NAPI_CALL_I
NAPI_MODULE_INIT() {
  napi_property_descriptor _init_wrap[] = {
').addBuf(lbInit).ail('
    {"_ammer_nodejs_tohaxecopy", NULL, _ammer_nodejs_tohaxecopy, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_nodejs_fromhaxecopy", NULL, _ammer_nodejs_fromhaxecopy, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_nodejs_tohaxeref", NULL, _ammer_nodejs_tohaxeref, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_nodejs_fromhaxeref", NULL, _ammer_nodejs_fromhaxeref, NULL, NULL, NULL, napi_default, NULL},

    {"_ammer_ref_create", NULL, _ammer_ref_create, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_ref_delete", NULL, _ammer_ref_delete, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_ref_getcount", NULL, _ammer_ref_getcount, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_ref_setcount", NULL, _ammer_ref_setcount, NULL, NULL, NULL, napi_default, NULL},
    {"_ammer_ref_getvalue", NULL, _ammer_ref_getvalue, NULL, NULL, NULL, napi_default, NULL},

    {"_ammer_init", NULL, _ammer_init, NULL, NULL, NULL, napi_default, NULL},
  };
  if (napi_define_properties(env, exports, ${exportCount + nativeCount}, _init_wrap) != napi_ok) return NULL;
  _ammer_nodejs_env = env;
  return exports;
}');
    outputPathRelative = '${config.name}.node';
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
        .ifi(args.length > 0)
          .ail('size_t _nodejs_argc = ${args.length};')
          .ail('napi_value _nodejs_argv[${args.length}];')
          .ail('NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));')
        .ifd();
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
    lbInit.ail('{"${name}", NULL, ${name}, NULL, NULL, NULL, napi_default, NULL},');
    exportCount++;
    tdefExtern.fields.push({
      pos: options.pos,
      name: name,
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType),
      access: [APublic, AStatic],
    });
    return macro (@:privateAccess $tdefExternExpr.$name);
  }

  function baseCall(
    lb:LineBuf,
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>,
    outputExpr:String,
    argExprs:Array<String>
  ):Void {
    lb
      .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l3l2(argExprs[idx], '_l2_arg_$idx'))
      .lmapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
      .ail('${ret.l1Type} _l1_output;')
      .ai('NAPI_CALL_I(napi_call_function(_nodejs_env, _l1_fn, _l1_fn, ${args.length}, ')
      .ifi(args.length > 0)
        .a('(napi_value[]){')
        .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
        .a("}")
      .ife()
        .a("NULL")
      .ifd()
      .al(", &_l1_output));")
      .ifi(ret.mangled != "v")
        .ail('${ret.l2Type} _l2_output;')
        .ail(ret.l1l2("_l1_output", "_l2_output"))
        .ail(ret.l2l3("_l2_output", outputExpr))
      .ifd();
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<NodejsTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    // TODO: what about rebound "this"?
    return new LineBuf()
      .ail("do {")
      .i()
        .ail('${clType.type.l2Type} _l2_fn;')
        .ail(clType.type.l3l2(fn, "_l2_fn"))
        .ail("napi_value _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("_ammer_haxe_ref* _l1_fn_ref2;")
        .ail("NAPI_CALL_I(napi_unwrap(_nodejs_env, _l1_fn_ref, (void**)&_l1_fn_ref2));")
        .ail('${clType.type.l1Type} _l1_fn;')
        .ail("NAPI_CALL_I(napi_get_reference_value(_nodejs_env, _l1_fn_ref2->value, &_l1_fn));")
        .apply(baseCall.bind(_, clType.ret, clType.args, outputExpr, args))
      .d()
      .ail("} while (0);")
      .done();
  }

  public function staticCall(
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>,
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
        .ail("napi_value scb;")
        .ail('NAPI_CALL_I(napi_get_reference_value(_nodejs_env, _ammer_haxe_scb, &scb));')
        .ail('napi_value _l1_fn;')
        .ail('NAPI_CALL_I(napi_get_element(_nodejs_env, scb, ${scbId}, &_l1_fn));')
        .apply(baseCall.bind(_, ret, args, outputExpr, argExprs))
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
    var napiCall = (ret == NodejsMarshal.MARSHAL_VOID ? "NAPI_CALL_V" : "NAPI_CALL");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail('#define NAPI_CALL_I $napiCall')
        .ail('napi_env _nodejs_env = _ammer_nodejs_env;')
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

@:allow(ammer.core.plat)
class NodejsMarshal extends BaseMarshal<
  NodejsMarshal,
  Nodejs,
  NodejsConfig,
  NodejsLibraryConfig,
  NodejsLibrary,
  NodejsTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):NodejsTypeMarshal {
    return {
      haxeType:  over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "napi_value", a Node.js tagged pointer (or boxed NaN)
      l1Type:   "napi_value",
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

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid(), {});
  public function void():NodejsTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
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

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    l1l2: MARSHAL_CAST_FROM_INT32("uint8_t", false),
    l2l1: MARSHAL_CAST_TO_INT32(false),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    l1l2: MARSHAL_CAST_FROM_INT32("int8_t", true),
    l2l1: MARSHAL_CAST_TO_INT32(true),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    l1l2: MARSHAL_CAST_FROM_INT32("uint16_t", false),
    l2l1: MARSHAL_CAST_TO_INT32(false),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    l1l2: MARSHAL_CAST_FROM_INT32("int16_t", true),
    l2l1: MARSHAL_CAST_TO_INT32(true),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2, &$l1));',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
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
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
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
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(), {
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

  public function enumInt(name:String, type:NodejsTypeMarshal):NodejsTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {});

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat64As32(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_double(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_double(_nodejs_env, $l2, &$l1));',
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_double(_nodejs_env, $l1, &$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_double(_nodejs_env, $l2, &$l1));',
  });
  public function float32():NodejsTypeMarshal return MARSHAL_FLOAT32;
  public function float64():NodejsTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    // TODO: mallocFunction
    // TODO: check malloc != null
    l1l2: (l1, l2) -> 'do {
  size_t _nodejs_tmp;
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, NULL, 0, &_nodejs_tmp));
  $l2 = (const char *)malloc(_nodejs_tmp + 1);
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, (char*)$l2, _nodejs_tmp + 1, &_nodejs_tmp));
} while (0);',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_string_utf8(_nodejs_env, $l2, NAPI_AUTO_LENGTH, &$l1));',
  });
  public function string():NodejsTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
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
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  } {
    var tdefExternExpr = library.tdefExternExpr;
    var pathBytesRef = baseBytesRef(
      (macro : Int), macro 0,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self:Dynamic = $self;
        var _size:Int = $size;
        var _res:js.lib.ArrayBuffer = (@:privateAccess $tdefExternExpr._ammer_nodejs_tohaxecopy)(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $tdefExternExpr._ammer_nodejs_fromhaxecopy)(_bytes.getData());
      },

      toHaxeRef: (self, size) -> macro {
        var _self:Dynamic = $self;
        var _size:Int = $size;
        var _res:js.lib.ArrayBuffer = (@:privateAccess $tdefExternExpr._ammer_nodejs_tohaxeref)(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromHaxeRef: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        var _ptr:Dynamic = (@:privateAccess $tdefExternExpr._ammer_nodejs_fromhaxeref)(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaqueInternal(name:String):NodejsTypeMarshal return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
    haxeType: (macro : Dynamic),
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  });

  function structPtrDerefInternal(name:String):NodejsTypeMarshal {
    return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
      haxeType: (macro : Dynamic),
      l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
      l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
    });
  }

  function arrayPtrInternalType(element:NodejsTypeMarshal):NodejsTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    haxeType: (macro : Dynamic),
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  });

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<NodejsTypeMarshal> {
    var tdefExternExpr = library.tdefExternExpr;
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : Dynamic),
      macro null,
      macro (@:privateAccess $tdefExternExpr._ammer_ref_getvalue)(handle),
      macro (@:privateAccess $tdefExternExpr._ammer_ref_getcount)(handle),
      rc -> macro (@:privateAccess $tdefExternExpr._ammer_ref_setcount)(handle, $rc),
      value -> macro (@:privateAccess $tdefExternExpr._ammer_ref_create)($value),
      macro (@:privateAccess $tdefExternExpr._ammer_ref_delete)(handle)
    );
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):NodejsTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
      haxeType: (macro : Dynamic),
      l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
      l2l1: (l2, l1) -> 'if ($l2 == NULL) {
  NAPI_CALL_I(napi_get_null(_nodejs_env, &$l1));
} else {
  NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));
}',
  });

  public function new(library:NodejsLibrary) {
    super(library);
  }
}

#end
