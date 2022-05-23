package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

@:allow(ammer.core.plat.Nodejs)
class NodejsMarshalSet extends BaseMarshalSet<
  NodejsMarshalSet,
  NodejsLibraryConfig,
  NodejsLibrary,
  NodejsTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

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

  static final MARSHAL_VOID:NodejsTypeMarshal = {
    haxeType: (macro : Void),
    l1Type: "napi_value",
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

  static final MARSHAL_BOOL:NodejsTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "napi_value",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_bool(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_get_boolean(_nodejs_env, $l2, &$l1));',
  };

  static final MARSHAL_UINT8:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "uint32_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2, &$l1));',
  };
  static final MARSHAL_INT8:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "int32_t",
    l3Type: "int8_t",
    mangled: "i8",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_int32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2, &$l1));',
  };
  static final MARSHAL_UINT16:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "uint32_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2, &$l1));',
  };
  static final MARSHAL_INT16:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "int32_t",
    l3Type: "int16_t",
    mangled: "i16",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_int32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2, &$l1));',
  };
  static final MARSHAL_UINT32:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_uint32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2, &$l1));',
  };
  static final MARSHAL_INT32:NodejsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "napi_value",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_int32(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2, &$l1));',
  };
  // TODO: a single _nodejs_tmp? per-function?
  // TODO: very verbose: wrap into macros?
  static final MARSHAL_UINT64:NodejsTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "napi_value",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
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
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'do {
  NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  napi_value _nodejs_tmp;
  NAPI_CALL_I(napi_create_uint32(_nodejs_env, ((uint64_t)$l2 >> 32) & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "high", _nodejs_tmp));
  NAPI_CALL_I(napi_create_uint32(_nodejs_env, $l2 & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "low", _nodejs_tmp));
} while (0);',
  };
  static final MARSHAL_INT64:NodejsTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "napi_value",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
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
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'do {
  NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
  napi_value _nodejs_tmp;
  NAPI_CALL_I(napi_create_int32(_nodejs_env, ((uint64_t)$l2 >> 32) & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "high", _nodejs_tmp));
  NAPI_CALL_I(napi_create_int32(_nodejs_env, $l2 & 0xFFFFFFFF, &_nodejs_tmp));
  NAPI_CALL_I(napi_set_named_property(_nodejs_env, $l1, "low", _nodejs_tmp));
} while (0);',
  };

  // static final MARSHAL_FLOAT32:NodejsTypeMarshal = {};
  static final MARSHAL_FLOAT64:NodejsTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "napi_value",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_get_value_double(_nodejs_env, $l1, &$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_double(_nodejs_env, $l2, &$l1));',
  };

  final MARSHAL_STRING:NodejsTypeMarshal;

  static final MARSHAL_BYTES:NodejsTypeMarshal = {
    haxeType: (macro : Dynamic),
    l1Type: "napi_value",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  };

  public function new(library:NodejsLibrary) {
    super(library);
    MARSHAL_STRING = {
      haxeType: (macro : String),
      l1Type: "napi_value",
      l2Type: "const char*",
      l3Type: "const char*",
      mangled: "s",
      // TODO: check malloc != null
      l1l2: (l1, l2) -> 'do {
  size_t _nodejs_tmp;
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, NULL, 0, &_nodejs_tmp));
  $l2 = (const char *)${library.config.mallocFunction}(_nodejs_tmp + 1);
  NAPI_CALL_I(napi_get_value_string_utf8(_nodejs_env, $l1, (char*)$l2, _nodejs_tmp + 1, &_nodejs_tmp));
} while (0);',
      l2ref: MARSHAL_NOOP1, // TODO: ref?
      l2l3: MARSHAL_CONVERT_DIRECT,
      l3l2: MARSHAL_CONVERT_DIRECT,
      l2unref: MARSHAL_NOOP1,
      l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_string_utf8(_nodejs_env, $l2, NAPI_AUTO_LENGTH, &$l1));',
    };
  }

  public function void():NodejsTypeMarshal return MARSHAL_VOID;

  public function bool():NodejsTypeMarshal return MARSHAL_BOOL;

  public function uint8():NodejsTypeMarshal return MARSHAL_UINT8;
  public function int8():NodejsTypeMarshal return MARSHAL_INT8;
  public function uint16():NodejsTypeMarshal return MARSHAL_UINT16;
  public function int16():NodejsTypeMarshal return MARSHAL_INT16;
  public function uint32():NodejsTypeMarshal return MARSHAL_UINT32;
  public function int32():NodejsTypeMarshal return MARSHAL_INT32;
  public function uint64():NodejsTypeMarshal return MARSHAL_UINT64;
  public function int64():NodejsTypeMarshal return MARSHAL_INT64;

  public function float32():NodejsTypeMarshal throw "!";
  public function float64():NodejsTypeMarshal return MARSHAL_FLOAT64;

  public function string():NodejsTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():NodejsTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:NodejsTypeMarshal,
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
      private function new(bytes:haxe.io.Bytes, ptr:Int) {
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
        @:privateAccess new $pathBytesRef(_bytes, _ptr);
      },
    };
  }

  function opaquePtrInternal(name:String):NodejsTypeMarshal return {
    haxeType: (macro : Dynamic),
    l1Type: "napi_value",
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: (l1, l2) -> 'NAPI_CALL_I(napi_unwrap(_nodejs_env, $l1, (void**)&$l2));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'NAPI_CALL_I(napi_create_object(_nodejs_env, &$l1));
NAPI_CALL_I(napi_wrap(_nodejs_env, $l1, $l2, NULL, NULL, NULL));',
  };

  function haxePtrInternal(haxeType:ComplexType):NodejsTypeMarshal return {
    haxeType: haxeType,
    l1Type: "napi_value",
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
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>
  ):NodejsTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "napi_value",
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
    var tdefs = [];
    for (lib in libraries) {
      var ext = lib.config.abi.extension();
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/binding.gyp'),
        // TODO: more configuration?
        WriteContent('{"targets": [{
  "target_name": "binding",
  "sources": ["lib.nodejs.$ext"]
}]}')
      ));
      var libCode = lib.lb
        .ail("#define NAPI_CALL_I NAPI_CALL
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
  memcpy(data_res, data, size);
  return res;
}
static napi_value _ammer_nodejs_frombytescopy(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {
  size_t _nodejs_argc = 1;
  napi_value _nodejs_argv[1];
  NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));
  uint8_t* data;
  size_t size;
  NAPI_CALL_I(napi_get_arraybuffer_info(_nodejs_env, _nodejs_argv[0], (void**)&data, &size));
  uint8_t* data_res = (uint8_t*)malloc(size);
  memcpy(data_res, data, size);
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
")
        .ail('NAPI_MODULE_INIT() {')
        .i()
          .ail("napi_property_descriptor _init_wrap[] = {")
          .a(lib.lbInit.done())
          .ail('{"_ammer_nodejs_tobytescopy", NULL, _ammer_nodejs_tobytescopy, NULL, NULL, NULL, 0, NULL},')
          .ail('{"_ammer_nodejs_frombytescopy", NULL, _ammer_nodejs_frombytescopy, NULL, NULL, NULL, 0, NULL},')
          .ail('{"_ammer_nodejs_tobytesref", NULL, _ammer_nodejs_tobytesref, NULL, NULL, NULL, 0, NULL},')
          .ail('{"_ammer_nodejs_frombytesref", NULL, _ammer_nodejs_frombytesref, NULL, NULL, NULL, 0, NULL},')
          .ail("};")
          .ail('if (napi_define_properties(env, exports, ${lib.exportCount + 4}, _init_wrap) != napi_ok) return NULL;')
          .ail('${lib.config.internalPrefix}registry.ctx = env;')
          .ail("return exports;")
        .d()
        .ail("}")
        .done();
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.nodejs.$ext'),
        WriteContent(libCode)
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
      for (tdef in lib.tdefs) {
        tdefs.push(tdef);
      }
    }
    return new BuildProgram(ops, tdefs);
  }
}

@:structInit
class NodejsConfig extends BaseConfig {
  public var nodeGypBinary:String = "node-gyp";
  // TODO: node-gyp config for electron etc?
}

@:allow(ammer.core.plat.Nodejs)
class NodejsLibrary extends BaseLibrary<
  NodejsLibrary,
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
      kind: FFun({
        ret: (macro : js.lib.ArrayBuffer),
        expr: null,
        args: [{
          type: (macro : Dynamic),
          name: "arg1",
        }, {
          type: (macro : Int),
          name: "arg2",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_frombytescopy",
      kind: FFun({
        ret: (macro : Dynamic),
        expr: null,
        args: [{
          type: (macro : js.lib.ArrayBuffer),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_tobytesref",
      kind: FFun({
        ret: (macro : js.lib.ArrayBuffer),
        expr: null,
        args: [{
          type: (macro : Dynamic),
          name: "arg1",
        }, {
          type: (macro : Int),
          name: "arg2",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_nodejs_frombytesref",
      kind: FFun({
        ret: (macro : Dynamic),
        expr: null,
        args: [{
          type: (macro : js.lib.ArrayBuffer),
          name: "arg1",
        }],
      }),
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

  public function addFunction(
    ret:NodejsTypeMarshal,
    args:Array<NodejsTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
    lb
      .ail('static ${ret.l1Type} ${name}(napi_env _nodejs_env, napi_callback_info _nodejs_cbinfo) {')
      .i()
        .ail('#define NAPI_CALL_I NAPI_CALL')
        .ail('size_t _nodejs_argc = ${args.length};')
        .ail('napi_value _nodejs_argv[${args.length}];')
        .ail('NAPI_CALL_I(napi_get_cb_info(_nodejs_env, _nodejs_cbinfo, &_nodejs_argc, _nodejs_argv, NULL, NULL));')
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_nodejs_argv[$idx]', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != NodejsMarshalSet.MARSHAL_VOID)
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
          .ail('${ret.l1Type} _l1_return;')
          .ail("NAPI_CALL_I(napi_get_undefined(_nodejs_env, &_l1_return));")
          .ail("return _l1_return;")
        .ifd()
        .ail("#undef NAPI_CALL_I")
      .d()
      .al("}");
    lbInit.ail('{"${name}", NULL, ${name}, NULL, NULL, NULL, 0, NULL},');
    exportCount++;
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: FFun({
        ret: ret.haxeType,
        expr: null,
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
        .ifi(clType.ret != NodejsMarshalSet.MARSHAL_VOID)
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
        .ifi(ret != NodejsMarshalSet.MARSHAL_VOID)
          .ail('${ret.l3Type} _return;')
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

typedef NodejsLibraryConfig = LibraryConfig;
typedef NodejsTypeMarshal = BaseTypeMarshal;

#end
