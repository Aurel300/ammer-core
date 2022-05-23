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
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

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

  static final MARSHAL_VOID:JavaTypeMarshal = {
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
    primitive: true,
    javaMangle: "V",
  };

  static final MARSHAL_BOOL:JavaTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "jboolean",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: (l1, l2) -> '$l2 = ($l1 == JNI_TRUE);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = ($l2 ? JNI_TRUE : JNI_FALSE);',
    primitive: true,
    javaMangle: "Z",
  };

  static final MARSHAL_UINT8:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jboolean",
    l2Type: "uint8_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "B", // ?
  };
  static final MARSHAL_INT8:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jbyte",
    l2Type: "uint8_t",
    l3Type: "uint8_t",
    mangled: "i8",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "B",
  };
  static final MARSHAL_UINT16:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jchar",
    l2Type: "uint16_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "C",
  };
  static final MARSHAL_INT16:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jshort",
    l2Type: "int16_t",
    l3Type: "int16_t",
    mangled: "i16",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "S",
  };
  static final MARSHAL_UINT32:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jint",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "I",
  };
  static final MARSHAL_INT32:JavaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "jint",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "I",
  };
  static final MARSHAL_UINT64:JavaTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "J",
  };
  static final MARSHAL_INT64:JavaTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "J",
  };

  static final MARSHAL_FLOAT32:JavaTypeMarshal = {
    haxeType: (macro : Single),
    l1Type: "jfloat",
    l2Type: "float",
    l3Type: "float",
    mangled: "f32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "F",
  };
  static final MARSHAL_FLOAT64:JavaTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "jdouble",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    javaMangle: "D",
  };

  static final MARSHAL_STRING:JavaTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "jstring",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    // TODO: avoid copy somehow? the release call is annoying in l2unref
    l1l2: (l1, l2) -> 'do {
  const char* _java_tmp = (*_java_env)->GetStringUTFChars(_java_env, $l1, NULL);
  $l2 = strdup(_java_tmp);
  (*_java_env)->ReleaseStringUTFChars(_java_env, $l1, $l2);
} while (0);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (*_java_env)->NewStringUTF(_java_env, $l2);',
    primitive: false,
    javaMangle: "Ljava/lang/String;",
  };

  static final MARSHAL_BYTES:JavaTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)$l1;',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (jlong)$l2;',
    primitive: false,
    javaMangle: "J",
  };

  public function new(library:JavaLibrary) {
    super(library);
  }

  public function void():JavaTypeMarshal return MARSHAL_VOID;

  public function bool():JavaTypeMarshal return MARSHAL_BOOL;

  public function uint8():JavaTypeMarshal return MARSHAL_UINT8;
  public function int8():JavaTypeMarshal return MARSHAL_INT8;
  public function uint16():JavaTypeMarshal return MARSHAL_UINT16;
  public function int16():JavaTypeMarshal return MARSHAL_INT16;
  public function uint32():JavaTypeMarshal return MARSHAL_UINT32;
  public function int32():JavaTypeMarshal return MARSHAL_INT32;
  public function uint64():JavaTypeMarshal return MARSHAL_UINT64;
  public function int64():JavaTypeMarshal return MARSHAL_INT64;

  public function float32():JavaTypeMarshal return MARSHAL_FLOAT32;
  public function float64():JavaTypeMarshal return MARSHAL_FLOAT64;

  public function string():JavaTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():JavaTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:JavaTypeMarshal,
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
      public var ptr(default, null):haxe.Int64;
      public function unref():Void {
        if (bytes != null) {
          (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytesunref")})(bytes.getData(), ptr);
          bytes = null;
          ptr = 0;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:haxe.Int64) {
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
        var _self:haxe.Int64 = $self;
        var _size:Int = $size;
        var _res:haxe.io.BytesData = (@:privateAccess $e{library.fieldExpr("_ammer_java_tobytescopy")})(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytescopy")})(_bytes.getData());
      },

      // TODO: this could work with java.nio.ByteBuffer but cannot override
      //   haxe.io.Bytes.get, so cannot provide a replacement for Bytes ...
      toBytesRef: null,

      fromBytesRef: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        var _ptr:haxe.Int64 = (@:privateAccess $e{library.fieldExpr("_ammer_java_frombytesref")})(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr));
      },
    };
  }

  function opaquePtrInternal(name:String):JavaTypeMarshal return {
    haxeType: (macro : haxe.Int64),
    l1Type: "jlong",
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: (l1, l2) -> '$l2 = ($name*)$l1;',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (jlong)$l2;',
    primitive: false,
    javaMangle: "J",
  };

  function haxePtrInternal(haxeType:ComplexType):JavaTypeMarshal return {
    haxeType: haxeType,
    l1Type: "jobject",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
    primitive: false,
    javaMangle: "?",
  };

  function closureInternal(
    ret:JavaTypeMarshal,
    args:Array<JavaTypeMarshal>
  ):JavaTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "jobject",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
    primitive: false,
    javaMangle: "?",
  };
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
      kind: FFun({
        ret: (macro : haxe.io.BytesData),
        expr: null,
        args: [{
          type: (macro : haxe.Int64),
          name: "arg1",
        }, {
          type: (macro : Int),
          name: "arg2",
        }],
      }),
      access: [APrivate, AStatic, AInline],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytescopy",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: FFun({
        ret: (macro : haxe.Int64),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic, AInline],
    });


    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytesref",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: FFun({
        ret: (macro : haxe.Int64),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic, AInline],
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_java_frombytesunref",
      meta: [{
        pos: config.pos,
        name: ":java.native",
      }],
      kind: FFun({
        ret: (macro : Void),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "arg1",
        }, {
          type: (macro : haxe.Int64),
          name: "arg2",
        }],
      }),
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
  uint8_t* data_res = (uint8_t*)malloc(size);
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

  public function addFunction(
    ret:JavaTypeMarshal,
    args:Array<JavaTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
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
        .ifi(ret != JavaMarshalSet.MARSHAL_VOID)
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
      kind: FFun({
        ret: ret.haxeType,
        expr: null,
        args: [ for (i => arg in args) {
          type: arg.haxeType,
          name: 'arg$i',
        } ],
      }),
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
        .ifi(clType.ret != JavaMarshalSet.MARSHAL_VOID)
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
        .ifi(clType.ret != JavaMarshalSet.MARSHAL_VOID)
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
        .ifi(clType.ret != JavaMarshalSet.MARSHAL_VOID)
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
    if (ret != JavaMarshalSet.MARSHAL_VOID) {
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

typedef JavaTypeMarshal = {
  >BaseTypeMarshal,
  primitive:Bool,
  javaMangle:String,
};

#end
