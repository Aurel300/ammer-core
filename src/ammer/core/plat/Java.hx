package ammer.core.plat;

#if macro

@:structInit
class JavaConfig extends BaseConfig {
  public var javaIncludePaths:Array<String> = null;
  public var javaLibraryPaths:Array<String> = null;
}

@:structInit
class JavaLibraryConfig extends LibraryConfig {
  public var jvm:Bool; // TODO: this should be on JavaConfig ...
}

typedef JavaTypeMarshalExt = {
  primitive:Bool,
  javaMangle:String,
  javaFullName:String,
};
typedef JavaTypeMarshal = {
  >BaseTypeMarshal,
  >JavaTypeMarshalExt,
};

class Java extends Base<
  Java,
  JavaConfig,
  JavaLibraryConfig,
  JavaTypeMarshal,
  JavaLibrary,
  JavaMarshal
> {
  public function new(config:JavaConfig) {
    super("java", config);
  }

  public function createLibrary(libConfig:JavaLibraryConfig):JavaLibrary {
    return new JavaLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.javaIncludePaths,
      libraryPaths: config.javaLibraryPaths,
      linkNames: ["jvm"],
    });
  }
}

@:allow(ammer.core.plat)
class JavaLibrary extends BaseLibrary<
  JavaLibrary,
  Java,
  JavaConfig,
  JavaLibraryConfig,
  JavaTypeMarshal,
  JavaMarshal
> {
  function pushNative(name:String, signature:ComplexType, pos:Position):Void {
    tdef.fields.push({
      pos: pos,
      name: name,
      meta: [{
        pos: pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt(signature),
      access: [APrivate, AStatic, AInline],
    });
  }

  public function new(platform:Java, config:JavaLibraryConfig) {
    super(platform, config, new JavaMarshal(this));
    tdef.meta.push({
      pos: config.pos,
      name: ":nativeGen",
    });

    // TODO: better names
    pushNative("_ammer_java_tohaxecopy",     (macro : (haxe.Int64, Int) -> haxe.io.BytesData), config.pos);
    pushNative("_ammer_java_fromhaxecopy",   (macro : (haxe.io.BytesData) -> haxe.Int64), config.pos);
    pushNative("_ammer_java_fromhaxeref",    (macro : (haxe.io.BytesData) -> haxe.Int64), config.pos);
    pushNative("_ammer_java_frombytesunref", (macro : (haxe.io.BytesData, haxe.Int64) -> Void), config.pos);

    pushNative("_ammer_ref_create",   (macro : (Dynamic) -> haxe.Int64), config.pos);
    pushNative("_ammer_ref_delete",   (macro : (haxe.Int64) -> Void), config.pos);
    pushNative("_ammer_ref_getcount", (macro : (haxe.Int64) -> Int), config.pos);
    pushNative("_ammer_ref_setcount", (macro : (haxe.Int64, Int) -> Void), config.pos);
    pushNative("_ammer_ref_getvalue", (macro : (haxe.Int64) -> Dynamic), config.pos);

    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          java.lang.System.loadLibrary($v{config.name});
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    lb.ail('
#include "jni.h"
JNIEXPORT jbyteArray ${javaMangle("_ammer_java_tohaxecopy")}(JNIEnv *_java_env, jclass _java_cls, jlong data, jint size) {
  jbyteArray res = (*_java_env)->NewByteArray(_java_env, size);
  (*_java_env)->SetByteArrayRegion(_java_env, res, 0, size, (const jbyte*)data);
  return res;
}
JNIEXPORT jlong ${javaMangle("_ammer_java_fromhaxecopy")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data) {
  jsize size = (*_java_env)->GetArrayLength(_java_env, data);
  uint8_t* data_res = (uint8_t*)${config.mallocFunction}(size);
  (*_java_env)->GetByteArrayRegion(_java_env, data, 0, size, (jbyte*)data_res);
  return (jlong)data_res;
}

JNIEXPORT jlong ${javaMangle("_ammer_java_fromhaxeref")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data) {
  uint8_t* data_res = (uint8_t*)((*_java_env)->GetByteArrayElements(_java_env, data, NULL));
  return (jlong)data_res;
}
JNIEXPORT void ${javaMangle("_ammer_java_frombytesunref")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data, jlong ptr) {
  (*_java_env)->ReleaseByteArrayElements(_java_env, data, (jbyte*)ptr, 0);
}

typedef struct { jobject value; int32_t refcount; } _ammer_haxe_ref;
JNIEXPORT jlong ${javaMangle("_ammer_ref_create")}(JNIEnv *_java_env, jclass _java_cls, jobject value) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = (*_java_env)->NewGlobalRef(_java_env, value);
  ref->refcount = 0;
  return (jlong)ref;
}
JNIEXPORT void ${javaMangle("_ammer_ref_delete")}(JNIEnv *_java_env, jclass _java_cls, jlong wref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)wref;
  (*_java_env)->DeleteGlobalRef(_java_env, ref->value);
  ref->value = NULL;
  ${config.freeFunction}(ref);
}
JNIEXPORT jint ${javaMangle("_ammer_ref_getcount")}(JNIEnv *_java_env, jclass _java_cls, jlong wref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)wref;
  return ref->refcount;
}
JNIEXPORT void ${javaMangle("_ammer_ref_setcount")}(JNIEnv *_java_env, jclass _java_cls, jlong wref, jint rc) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)wref;
  ref->refcount = rc;
}
JNIEXPORT jobject ${javaMangle("_ammer_ref_getvalue")}(JNIEnv *_java_env, jclass _java_cls, jlong wref) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)wref;
  return ref->value;
}
');
    // TODO: multithread attach/detach counting?
    // TODO: configure JNI version?
    // https://docs.oracle.com/javase/9/docs/specs/jni/invocation.html#jni_onload

    lb.ail('
JavaVM* ${config.internalPrefix}ctx;
jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  ${config.internalPrefix}ctx = vm;
  return JNI_VERSION_1_6;
}');
  }

  function javaMangle(
    method:String
    // TODO: module ?
  ):String {
    var pack = config.typeDefPack;
    var type = config.typeDefName;
    pack = pack.length > 0 ? pack : ["haxe", "root"];
    function subMangle(s:String):String {
      // TODO: more thorough mangling
      return s.replace("_", "_1");
    }
    return 'Java_${pack.join("_")}_${subMangle(type)}_${subMangle(method)}';
  }

  public function addNamedFunction(
    name:String,
    ret:JavaTypeMarshal,
    args:Array<JavaTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    var mangledName = javaMangle(name);
    lb
      .ai('JNIEXPORT ${ret.l1Type} $mangledName(JNIEnv *_java_env, jclass _java_cls')
      .mapi(args, (idx, arg) -> ', ${arg.l1Type} _l1_arg_$idx')
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
        .ifd()
      .d()
      .ail("}");
    tdef.fields.push({
      pos: options.pos,
      name: name,
      meta: [{
        pos: options.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType),
      access: [APublic, AStatic, AInline],
    });
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<JavaTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    // TODO: ref/unref args?
    var lb = new LineBuf()
      .ail("do {")
      .i()
        .ail('${clType.type.l2Type} _l2_fn;')
        .ail(clType.type.l3l2(fn, "_l2_fn"))
        .ail("jlong _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("jobject _l1_fn;")
        .ail("_l1_fn = ((_ammer_haxe_ref*)_l1_fn_ref)->value;")
        .ail("jclass _l1_fn_cls = (*_java_env)->GetObjectClass(_java_env, _l1_fn);")
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l3l2(arg, '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'));
    if (config.jvm) {
      lb
        .ai('jmethodID _java_method = (*_java_env)->GetMethodID(_java_env, _l1_fn_cls, "invoke", "(')
        .mapi(args, (idx, arg) -> clType.args[idx].javaMangle)
        .al(')${clType.ret.javaMangle}");')
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai("_l1_output = (*_java_env)->Call")
        .ife()
          .ai("(*_java_env)->Call")
        .ifd()
        .a(clType.ret.javaFullName)
        .a("Method(_java_env, _l1_fn, _java_method")
        .mapi(args, (idx, arg) -> ', _l1_arg_${idx}')
        .al(');');
    } else {
      lb
        .ail('jclass _java_class = (*_java_env)->FindClass(_java_env, "java/lang/Class");')
        .ai('jmethodID _java_method = (*_java_env)->GetMethodID(_java_env, _l1_fn_cls, ')
        .a('"__hx_invoke${args.length}_${clType.ret.primitive ? "f" : "o"}", "(')
        .map(args, arg -> "DLjava/lang/Object;")
        .al(')${clType.ret.primitive ? "D" : "Ljava/lang/Object;"}");')
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai('_l1_output = (${clType.ret.l1Type})')
        .ife()
          .ai("")
        .ifd()
        .a(clType.ret.primitive
          ? '(*_java_env)->CallDoubleMethod(_java_env, _l1_fn, _java_method'
          : '(*_java_env)->CallObjectMethod(_java_env, _l1_fn, _java_method')
        .mapi(args, (idx, arg) -> clType.args[idx].primitive
          ? ', (jdouble)_l1_arg_${idx}, _java_undef'
          : ', 0.0, _l1_arg_${idx}')
        .al(');');
    }
    return lb
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function staticCall(
    ret:JavaTypeMarshal,
    args:Array<JavaTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    var name = baseStaticCall(ret, args, code);
    return new LineBuf()
      .ail("do {")
      .i()
        .lmapi(args, (idx, arg) -> '${args[idx].l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> args[idx].l3l2(argExprs[idx], '_l2_arg_${idx}'))
        .lmapi(args, (idx, arg) -> '${args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> args[idx].l2l1('_l2_arg_${idx}', '_l1_arg_${idx}'))
        .ail('jclass _java_scb = (*_java_env)->FindClass(_java_env, "${tdefStaticCallbacks.pack.join("/")}/${tdefStaticCallbacks.name}");')
        .ai('jmethodID _java_scb_method = (*_java_env)->GetStaticMethodID(_java_env, _java_scb, "${name}", "(')
        .map(args, arg -> arg.javaMangle)
        .a(")")
        .a(ret.javaMangle)
        .al('");')
        .ifi(ret.mangled != "v")
          .ail('${ret.l1Type} _l1_output;')
          .ai("_l1_output = (*_java_env)->CallStatic")
        .ife()
          .ai("(*_java_env)->CallStatic")
        .ifd()
        .a(ret.javaFullName)
        .a("Method(_java_env, _java_scb, _java_scb_method")
        .mapi(args, (idx, arg) -> ', _l1_arg_$idx')
        .al(');')
        .ifi(ret.mangled != "v")
          .ail('${ret.l2Type} _l2_output;')
          .ail(ret.l1l2("_l1_output", "_l2_output"))
          .ail(ret.l2l3("_l2_output", outputExpr))
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:JavaTypeMarshal,
    args:Array<JavaTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail('JavaVM* _java_vm = ${config.internalPrefix}ctx;')
        .ail('JNIEnv* _java_env;')
        .ail('(*_java_vm)->AttachCurrentThread(_java_vm, (void**)&_java_env, NULL);')
        .ifi(!config.jvm)
          .ail('jclass _java_runtime = (*_java_env)->FindClass(_java_env, "haxe/lang/Runtime");')
          .ail('jfieldID _java_undef_f = (*_java_env)->GetStaticFieldID(_java_env, _java_runtime, "undefined", "Ljava/lang/Object;");')
          .ail('jobject _java_undef = (*_java_env)->GetStaticObjectField(_java_env, _java_runtime, _java_undef_f);')
        .ifd()
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
class JavaMarshal extends BaseMarshal<
  JavaMarshal,
  Java,
  JavaConfig,
  JavaLibraryConfig,
  JavaLibrary,
  JavaTypeMarshal
> {
  // Primitive types
  // https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/types.html#primitive_types

  static function baseExtend(
    base:BaseTypeMarshal,
    ext:JavaTypeMarshalExt,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):JavaTypeMarshal {
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
      primitive: ext.primitive,
      javaMangle: ext.javaMangle,
      javaFullName: ext.javaFullName,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid(), {
    primitive: true,
    javaMangle: "V",
    javaFullName: "Void",
  });
  public function void():JavaTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
    primitive: true,
    javaMangle: "Z",
    javaFullName: "Boolean",
  }, {
    l1Type: "jboolean",
    l1l2: (l1, l2) -> '$l2 = ($l1 == JNI_TRUE);',
    l2l1: (l2, l1) -> '$l1 = ($l2 ? JNI_TRUE : JNI_FALSE);',
  });
  public function bool():JavaTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    primitive: true,
    javaMangle: "Z",
    javaFullName: "Boolean",
  }, {
    l1Type: "jboolean",
    // TODO: there is no java.types.Uint8, so u8 arrays use i8
    arrayType: (macro : java.types.Int8),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    primitive: true,
    javaMangle: "B",
    javaFullName: "Byte",
  }, {
    l1Type: "jbyte",
    arrayType: (macro : java.types.Int8),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    primitive: true,
    javaMangle: "C",
    javaFullName: "Char",
  }, {
    l1Type: "jchar",
    arrayType: (macro : java.types.Char16),
  });

  #if (haxe >= version("4.2.6")) // "can't compare S and S" until PR#10722
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    primitive: true,
    javaMangle: "S",
    javaFullName: "Short",
  }, {
    l1Type: "jshort",
    arrayType: (macro : java.types.Int16),
  });
  #else
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    primitive: true,
    javaMangle: "C",
    javaFullName: "Short",
  }, {
    l1Type: "jshort",
    arrayType: (macro : java.types.Char16),
  });
  #end

  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    primitive: true,
    javaMangle: "I",
    javaFullName: "Int",
  }, {
    l1Type: "jint",
    arrayType: (macro : Int),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
    primitive: true,
    javaMangle: "I",
    javaFullName: "Int",
  }, {
    l1Type: "jint",
    arrayType: (macro : Int),
  });
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    primitive: true,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    l1Type: "jlong",
    arrayType: (macro : haxe.Int64),
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshal.baseInt64(), {
    primitive: true,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    l1Type: "jlong",
    arrayType: (macro : haxe.Int64),
  });
  public function uint8():JavaTypeMarshal return MARSHAL_UINT8;
  public function int8():JavaTypeMarshal return MARSHAL_INT8;
  public function uint16():JavaTypeMarshal return MARSHAL_UINT16;
  public function int16():JavaTypeMarshal return MARSHAL_INT16;
  public function uint32():JavaTypeMarshal return MARSHAL_UINT32;
  public function int32():JavaTypeMarshal return MARSHAL_INT32;
  public function uint64():JavaTypeMarshal return MARSHAL_UINT64;
  public function int64():JavaTypeMarshal return MARSHAL_INT64;

  public function enumInt(name:String, type:JavaTypeMarshal):JavaTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {
      primitive: true,
      javaMangle: type.javaMangle,
      javaFullName: type.javaFullName,
    });

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {
    primitive: true,
    javaMangle: "F",
    javaFullName: "Float",
  }, {
    l1Type: "jfloat",
    arrayType: (macro : Single),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    primitive: true,
    javaMangle: "D",
    javaFullName: "Double",
  }, {
    l1Type: "jdouble",
    arrayType: (macro : Float),
  });
  public function float32():JavaTypeMarshal return MARSHAL_FLOAT32;
  public function float64():JavaTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    primitive: false,
    javaMangle: "Ljava/lang/String;",
    javaFullName: "Object",
  }, {
    l1Type: "jstring",
    // TODO: avoid copy somehow?
    l1l2: (l1, l2) -> 'do {
  const char* _java_tmp = (*_java_env)->GetStringUTFChars(_java_env, $l1, NULL);
  $l2 = strdup(_java_tmp);
  (*_java_env)->ReleaseStringUTFChars(_java_env, $l1, _java_tmp);
} while (0);',
    l2l1: (l2, l1) -> '$l1 = (*_java_env)->NewStringUTF(_java_env, $l2);',
  });
  public function string():JavaTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    primitive: false,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST("uint8_t*"),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("jlong"),
  });
  function bytesInternalType():JavaTypeMarshal return MARSHAL_BYTES;
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
      (macro : haxe.Int64), macro 0,
      (macro : Int), macro 0, // handle unused
      macro (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytesunref")})(bytes.getData(), ptr)
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : haxe.Int64);
        var _size = ($size : Int);
        var _res:haxe.io.BytesData = (@:privateAccess $e{library.fieldExpr("_ammer_java_tohaxecopy")})(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        (@:privateAccess $e{library.fieldExpr("_ammer_java_fromhaxecopy")})(_bytes.getData());
      },

      // TODO: this could work with java.nio.ByteBuffer but cannot override
      //   haxe.io.Bytes.get, so cannot provide a replacement for Bytes ...
      toHaxeRef: null,

      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr:haxe.Int64 = (@:privateAccess $e{library.fieldExpr("_ammer_java_fromhaxeref")})(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaqueInternal(name:String):JavaTypeMarshal return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
    primitive: true,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST(name),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("jlong"),
  });

  function structPtrDerefInternal(name:String):JavaTypeMarshal return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
    primitive: true,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST('$name*'),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("jlong"),
  });

  function arrayPtrInternalType(element:JavaTypeMarshal):JavaTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    primitive: false, // TODO: why?
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST('${element.l2Type}*'),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("jlong"),
  });
  override function arrayPtrInternalOps(
    type:JavaTypeMarshal,
    element:JavaTypeMarshal,
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
    var vectorDataType = (macro : java.NativeArray<$elType>);

    var copyTo = '_ammer_java_toarraycopy_${element.mangled}';
    var copyFrom = '_ammer_java_fromarraycopy_${element.mangled}';
    var refFrom = '_ammer_java_toarrayref_${element.mangled}';
    var unrefFrom = '_ammer_java_fromarrayunref_${element.mangled}';
    library.tdef.fields.push({
      pos: library.config.pos,
      name: copyTo,
      meta: [{
        pos: library.config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : (haxe.Int64, Int) -> $vectorDataType)),
      access: [APrivate, AStatic, AInline],
    });
    library.tdef.fields.push({
      pos: library.config.pos,
      name: copyFrom,
      meta: [{
        pos: library.config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : ($vectorDataType) -> haxe.Int64)),
      access: [APrivate, AStatic, AInline],
    });
    library.tdef.fields.push({
      pos: library.config.pos,
      name: refFrom,
      meta: [{
        pos: library.config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : ($vectorDataType) -> haxe.Int64)),
      access: [APrivate, AStatic, AInline],
    });
    library.tdef.fields.push({
      pos: library.config.pos,
      name: unrefFrom,
      meta: [{
        pos: library.config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : ($vectorDataType, haxe.Int64) -> Void)),
      access: [APrivate, AStatic, AInline],
    });
    var arrayRoot = (switch (element.mangled) {
      case "u8":          "byte"; // "boolean";
      case "i8":          "byte";
      case "u16":         "char";
      #if (haxe >= version("4.2.6")) // "can't compare S and S" until PR#10722
      case "i16":         "short";
      #else
      case "i16":         "char";
      #end
      case "u32" | "i32": "int";
      case "u64" | "i64": "long";
      case "f32":         "float";
      case "f64":         "double";
      case _: throw 0;
    });
    var arrayName = 'j${arrayRoot}Array';
    var arrayOp = arrayRoot.charAt(0).toUpperCase() + arrayRoot.substr(1);
    library.lb.ail('
JNIEXPORT $arrayName ${library.javaMangle(copyTo)}(JNIEnv *_java_env, jclass _java_cls, jlong data, jint size) {
  $arrayName res = (*_java_env)->New${arrayOp}Array(_java_env, size);
  (*_java_env)->Set${arrayOp}ArrayRegion(_java_env, res, 0, size, (const j${arrayRoot}*)data);
  return res;
}
JNIEXPORT jlong ${library.javaMangle(copyFrom)}(JNIEnv *_java_env, jclass _java_cls, $arrayName data) {
  jsize size = (*_java_env)->GetArrayLength(_java_env, data);
  uint8_t* data_res = (uint8_t*)${library.config.mallocFunction}(size << ${element.arrayBits});
  (*_java_env)->Get${arrayOp}ArrayRegion(_java_env, data, 0, size, (j${arrayRoot}*)data_res);
  return (jlong)data_res;
}

JNIEXPORT jlong ${library.javaMangle(refFrom)}(JNIEnv *_java_env, jclass _java_cls, $arrayName data) {
  uint8_t* data_res = (uint8_t*)((*_java_env)->Get${arrayOp}ArrayElements(_java_env, data, NULL));
  return (jlong)data_res;
}
JNIEXPORT void ${library.javaMangle(unrefFrom)}(JNIEnv *_java_env, jclass _java_cls, $arrayName data, jlong ptr) {
  (*_java_env)->Release${arrayOp}ArrayElements(_java_env, data, (j${arrayRoot}*)ptr, 0);
}
');

    var pathArrayRef = baseArrayRef(
      element, vectorType,
      (macro : haxe.Int64), macro 0,
      (macro : Int), macro 0, // handle unused
      macro (@:privateAccess $e{library.fieldExpr(unrefFrom)})(vector.toData(), ptr)
    );
    return {
      vectorType: vectorType,
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : haxe.Int64);
        var _size = ($size : Int);
        var _res:$vectorDataType = (@:privateAccess $e{library.fieldExpr(copyTo)})(_self, _size);
        haxe.ds.Vector.fromData(_res);
      },
      fromHaxeCopy: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        (@:privateAccess $e{library.fieldExpr(copyFrom)})(_vector.toData());
      },

      toHaxeRef: null,
      fromHaxeRef: (vector) -> macro {
        var _vector = ($vector : $vectorType);
        var _ptr:haxe.Int64 = (@:privateAccess $e{library.fieldExpr(refFrom)})(_vector.toData());
        (@:privateAccess new $pathArrayRef(_vector, _ptr, 0));
      },
    };
  }

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<JavaTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : haxe.Int64),
      macro 0,
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getvalue")})(handle),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_getcount")})(handle),
      rc -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_setcount")})(handle, $rc),
      value -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_create")})($value),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_delete")})(handle)
    );
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):JavaTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    primitive: true,
    javaMangle: "J",
    javaFullName: "Long",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST("void*"),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("jlong"),
  });

  public function new(library:JavaLibrary) {
    super(library);
  }
}

#end
