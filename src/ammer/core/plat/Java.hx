package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using StringTools;

@:allow(ammer.core.plat.Java)
class JavaMarshalSet extends BaseMarshalSet<
  JavaMarshalSet,
  JavaLibraryConfig,
  JavaLibrary,
  JavaTypeMarshal
> {
  // TODO: ${config.internalPrefix}
  // TODO: this already roots
  static final MARSHAL_REGISTRY_GET_NODE = (l1:String, l2:String)
    -> '$l2 = _ammer_core_registry_get((void*)_ammer_ctr++);
$l2->ref = (*_java_env)->NewGlobalRef(_java_env, $l1);';
  static final MARSHAL_REGISTRY_REF = (l2:String)
    -> '_ammer_core_registry_incref($l2);';
  static final MARSHAL_REGISTRY_UNREF = (l2:String)
    -> '_ammer_core_registry_decref($l2);';
  static final MARSHAL_REGISTRY_GET_KEY = (l2:String, l1:String) // TODO: target type cast
    -> '$l1 = $l2->ref;';

  // Primitive types
  // https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/types.html#primitive_types

  // TODO: javaMangle ...

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
      l2ref:     over != null && over.l2ref     != null ? over.l2ref     : base.l2ref,
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2unref:   over != null && over.l2unref   != null ? over.l2unref   : base.l2unref,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
      primitive: ext.primitive,
      javaMangle: ext.javaMangle,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshalSet.baseVoid(), {primitive: true, javaMangle: "V"});
  public function void():JavaTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshalSet.baseBool(), {primitive: true, javaMangle: "Z"}, {
    l1Type: "jboolean",
    l1l2: (l1, l2) -> '$l2 = ($l1 == JNI_TRUE);',
    l2l1: (l2, l1) -> '$l1 = ($l2 ? JNI_TRUE : JNI_FALSE);',
  });
  public function bool():JavaTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshalSet.baseUint8(), {
    primitive: true,
    // TODO: there is no java.types.Uint8, so u8 arrays use i8
    javaMangle: "B", //javaMangle: "Z",
  }, {
    // l1Type: "jboolean",
    l1Type: "jbyte",
    arrayType: (macro : java.types.Int8),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshalSet.baseInt8(), {primitive: true, javaMangle: "B"}, {
    l1Type: "jbyte",
    arrayType: (macro : java.types.Int8),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshalSet.baseUint16(), {primitive: true, javaMangle: "C"}, {
    l1Type: "jchar",
    arrayType: (macro : java.types.Char16),
  });
  // TODO: "can't compare S and S" until PR#10722
  static final MARSHAL_INT16 = baseExtend(BaseMarshalSet.baseInt16(), {primitive: true, javaMangle: "S"}, {
    l1Type: "jshort",
    arrayType: (macro : java.types.Int16),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshalSet.baseUint32(), {primitive: true, javaMangle: "I"}, {
    l1Type: "jint",
    arrayType: (macro : Int),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshalSet.baseInt32(), {primitive: true, javaMangle: "I"}, {
    l1Type: "jint",
    arrayType: (macro : Int),
  });
  static final MARSHAL_UINT64 = baseExtend(BaseMarshalSet.baseUint64(), {primitive: true, javaMangle: "J"}, {
    l1Type: "jlong",
    arrayType: (macro : haxe.Int64),
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshalSet.baseInt64(), {primitive: true, javaMangle: "J"}, {
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

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshalSet.baseFloat32(), {primitive: true, javaMangle: "F"}, {
    l1Type: "jfloat",
    arrayType: (macro : Single),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshalSet.baseFloat64(), {primitive: true, javaMangle: "D"}, {
    l1Type: "jdouble",
    arrayType: (macro : Float),
  });
  public function float32():JavaTypeMarshal return MARSHAL_FLOAT32;
  public function float64():JavaTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshalSet.baseString(), {primitive: false, javaMangle: "Ljava/lang/String;"}, {
    l1Type: "jstring",
    // TODO: avoid copy somehow? the release call is annoying in l2unref
    l1l2: (l1, l2) -> 'do {
  const char* _java_tmp = (*_java_env)->GetStringUTFChars(_java_env, $l1, NULL);
  $l2 = strdup(_java_tmp);
  (*_java_env)->ReleaseStringUTFChars(_java_env, $l1, $l2);
} while (0);',
    l2l1: (l2, l1) -> '$l1 = (*_java_env)->NewStringUTF(_java_env, $l2);',
  });
  public function string():JavaTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshalSet.baseBytesInternal(), {primitive: false, javaMangle: "J"}, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshalSet.MARSHAL_CONVERT_CAST("uint8_t*"),
    l2l1: BaseMarshalSet.MARSHAL_CONVERT_CAST("jlong"),
  });
  function bytesInternalType():JavaTypeMarshal return MARSHAL_BYTES;
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
      (macro : haxe.Int64), macro 0,
      (macro : Int), macro 0, // handle unused
      macro (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytesunref")})(bytes.getData(), ptr)
    );
    return {
      toBytesCopy: (self, size) -> macro {
        var _self = ($self : haxe.Int64);
        var _size = ($size : Int);
        var _res:haxe.io.BytesData = (@:privateAccess $e{library.fieldExpr("_ammer_java_tobytescopy")})(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytescopy")})(_bytes.getData());
      },

      // TODO: this could work with java.nio.ByteBuffer but cannot override
      //   haxe.io.Bytes.get, so cannot provide a replacement for Bytes ...
      toBytesRef: null,

      fromBytesRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr:haxe.Int64 = (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytesref")})(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaquePtrInternal(name:String):JavaTypeMarshal return baseExtend(BaseMarshalSet.baseOpaquePtrInternal(name), {
    primitive: false,
    javaMangle: "J",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshalSet.MARSHAL_CONVERT_CAST('$name*'),
    l2l1: BaseMarshalSet.MARSHAL_CONVERT_CAST("jlong"),
  });

  function arrayPtrInternalType(element:JavaTypeMarshal):JavaTypeMarshal return baseExtend(BaseMarshalSet.baseArrayPtrInternal(element), {
    primitive: false,
    javaMangle: "J",
  }, {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l1l2: BaseMarshalSet.MARSHAL_CONVERT_CAST('${element.l2Type}*'),
    l2l1: BaseMarshalSet.MARSHAL_CONVERT_CAST("jlong"),
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
      case "i16":         "short";
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

  function haxePtrInternal(haxeType:ComplexType):JavaTypeMarshal return baseExtend(BaseMarshalSet.baseHaxePtrInternal(haxeType), {
    primitive: false,
    javaMangle: "Ljava/lang/Object;",
  }, {
    haxeType: haxeType,
    l1Type: "jobject",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  });

  public function new(library:JavaLibrary) {
    super(library);
  }
}

class Java extends Base<
  JavaConfig,
  JavaLibraryConfig,
  JavaTypeMarshal,
  JavaLibrary,
  JavaMarshalSet
> {
  public function new(config:JavaConfig) {
    super("java", config);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.javaIncludePaths,
      libraryPaths: config.javaLibraryPaths,
    });
  }
}

@:structInit
class JavaConfig extends BaseConfig {
  public var javaIncludePaths:Array<String> = null;
  public var javaLibraryPaths:Array<String> = null;
}

@:allow(ammer.core.plat.Java)
class JavaLibrary extends BaseLibrary<
  JavaLibrary,
  JavaLibraryConfig,
  JavaTypeMarshal,
  JavaMarshalSet
> {
  public function new(config:JavaLibraryConfig) {
    super(config, new JavaMarshalSet(this));
    tdef.meta.push({
      pos: config.pos,
      name: ":nativeGen",
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_tobytescopy",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : (haxe.Int64, Int) -> haxe.io.BytesData)),
      access: [APrivate, AStatic, AInline],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytescopy",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData) -> haxe.Int64)),
      access: [APrivate, AStatic, AInline],
    });

    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytesref",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData) -> haxe.Int64)),
      access: [APrivate, AStatic, AInline],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytesunref",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData, haxe.Int64) -> Void)),
      access: [APrivate, AStatic, AInline],
    });

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
    lb.ail("#include <jni.h>");
    lb.ail("static size_t _ammer_ctr = 0;"); // TODO: internalPrefix
    boilerplate(
      "JavaVM*",
      "void*",
      "jobject ref;",
      "",
      'JavaVM* _java_vm = ${config.internalPrefix}registry.ctx;
JNIEnv* _java_env;
(*_java_vm)->GetEnv(_java_vm, (void**)&_java_env, JNI_VERSION_1_6);
(*_java_env)->DeleteGlobalRef(_java_env, curr->ref);'
    );
    lb.ail('
JNIEXPORT jbyteArray ${javaMangle("_ammer_java_tobytescopy")}(JNIEnv *_java_env, jclass _java_cls, jlong data, jint size) {
  jbyteArray res = (*_java_env)->NewByteArray(_java_env, size);
  (*_java_env)->SetByteArrayRegion(_java_env, res, 0, size, (const jbyte*)data);
  return res;
}
JNIEXPORT jlong ${javaMangle("_ammer_java_frombytescopy")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data) {
  jsize size = (*_java_env)->GetArrayLength(_java_env, data);
  uint8_t* data_res = (uint8_t*)${config.mallocFunction}(size);
  (*_java_env)->GetByteArrayRegion(_java_env, data, 0, size, (jbyte*)data_res);
  return (jlong)data_res;
}

JNIEXPORT jlong ${javaMangle("_ammer_java_frombytesref")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data) {
  uint8_t* data_res = (uint8_t*)((*_java_env)->GetByteArrayElements(_java_env, data, NULL));
  return (jlong)data_res;
}
JNIEXPORT void ${javaMangle("_ammer_java_frombytesunref")}(JNIEnv *_java_env, jclass _java_cls, jbyteArray data, jlong ptr) {
  (*_java_env)->ReleaseByteArrayElements(_java_env, data, (jbyte*)ptr, 0);
}
');
    // TODO: multithread attach/detach counting?
    // TODO: configure JNI version?
    // https://docs.oracle.com/javase/9/docs/specs/jni/invocation.html#jni_onload
    lb.ail('jint JNI_OnLoad(JavaVM* vm, void* reserved) {
  ${config.internalPrefix}registry.ctx = vm;
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
    pos:Position
  ):Expr {
    var mangledName = javaMangle(name);
    lb
      .ai('JNIEXPORT ${ret.l1Type} $mangledName(JNIEnv *_java_env, jclass _java_cls')
      .mapi(args, (idx, arg) -> ', ${arg.l1Type} _l1_arg_$idx')
      .al(') {')
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_l1_arg_$idx', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret.mangled != "v")
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
    tdef.fields.push({
      pos: Context.currentPos(),
      name: name,
      meta: [{
        pos: Context.currentPos(),
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
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l3l2(arg, '_l2_arg_$idx'))
        .ail('${clType.type.l1Type} _l1_fn;')
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn"))
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ail("jclass _l1_fn_cls = (*_java_env)->GetObjectClass(_java_env, _l1_fn);");
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
        .a(switch (clType.ret) {
          case JavaMarshalSet.MARSHAL_VOID: "Void";
          case JavaMarshalSet.MARSHAL_BOOL: "Boolean";
          case JavaMarshalSet.MARSHAL_UINT8: "Boolean";
          case JavaMarshalSet.MARSHAL_INT8: "Byte";
          case JavaMarshalSet.MARSHAL_UINT16: "Char";
          case JavaMarshalSet.MARSHAL_INT16: "Short";
          case JavaMarshalSet.MARSHAL_UINT32: "Int";
          case JavaMarshalSet.MARSHAL_INT32: "Int";
          case JavaMarshalSet.MARSHAL_UINT64: "Long";
          case JavaMarshalSet.MARSHAL_INT64: "Long";
          case JavaMarshalSet.MARSHAL_FLOAT32: "Float";
          case JavaMarshalSet.MARSHAL_FLOAT64: "Double";
          case _: "Object";
        })
        .a("Method(_java_env, _l1_fn, _java_method")
        .mapi(args, (idx, arg) -> ', _l1_arg_${idx}')
        .al(');');
    } else {
      lb
        .ail('jclass _java_class = (*_java_env)->FindClass(_java_env, "java/lang/Class");')
        .ail('jmethodID _java_name = (*_java_env)->GetMethodID(_java_env, _java_class, "getName", "()Ljava/lang/String;");')
        .ail('jstring _java_name_fn = (*_java_env)->CallObjectMethod(_java_env, _l1_fn_cls, _java_name);')
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
        .ail('JavaVM* _java_vm = ${config.internalPrefix}registry.ctx;')
        .ail('JNIEnv* _java_env;')
        .ail('(*_java_vm)->AttachCurrentThread(_java_vm, (void**)&_java_env, NULL);');
    if (!config.jvm) {
      lb
        .ail('jclass _java_runtime = (*_java_env)->FindClass(_java_env, "haxe/lang/Runtime");')
        .ail('jfieldID _java_undef_f = (*_java_env)->GetStaticFieldID(_java_env, _java_runtime, "undefined", "Ljava/lang/Object;");')
        .ail('jobject _java_undef = (*_java_env)->GetStaticObjectField(_java_env, _java_runtime, _java_undef_f);');
    }
    if (ret.mangled != "v") {
      lb
        .ail('${ret.l3Type} ${config.returnIdent};')
        .ail(code)
        .ail('return ${config.returnIdent};');
    } else {
      lb
        .ail(code);
    }
    // TODO: detach???
    lb
      .d()
      .al("}");
    return name;
  }
}

@:structInit
class JavaLibraryConfig extends LibraryConfig {
  public var jvm:Bool; // TODO: this should be on JavaConfig ...
}
typedef JavaTypeMarshalExt = {
  primitive:Bool,
  javaMangle:String,
};
typedef JavaTypeMarshal = {
  >BaseTypeMarshal,
  >JavaTypeMarshalExt,
};

#end
