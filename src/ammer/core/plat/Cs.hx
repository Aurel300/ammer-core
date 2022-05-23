package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;
using StringTools;

@:allow(ammer.core.plat.Cs)
class CsMarshalSet extends BaseMarshalSet<
  CsMarshalSet,
  CsLibraryConfig,
  CsLibrary,
  CsTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

  // The implementation is a noop but the identity of the function is used to
  // identify when ref/unref should happen in a C# wrapper.
  static final MARSHAL_REGISTRY_REF = (_:String) -> "";
  static final MARSHAL_REGISTRY_UNREF = (_:String) -> "";

  static final MARSHAL_VOID:CsTypeMarshal = {
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
    csType: "void",
  };

  static final MARSHAL_BOOL:CsTypeMarshal = {
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
    primitive: true,
    csType: "bool",
  };

  static final MARSHAL_UINT8:CsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "uint8_t",
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
    csType: "byte",
  };
  static final MARSHAL_INT8:CsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int8_t",
    l2Type: "int8_t",
    l3Type: "int8_t",
    mangled: "i8",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: true,
    csType: "sbyte",
  };
  static final MARSHAL_UINT16:CsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "uint16_t",
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
    csType: "ushort",
  };
  static final MARSHAL_INT16:CsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int16_t",
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
    csType: "short",
  };
  static final MARSHAL_UINT32:CsTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "uint32_t",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    // csType: "uint",
    primitive: true,
    csType: "int", // see Haxe#5258
  };
  static final MARSHAL_INT32:CsTypeMarshal = {
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
    primitive: true,
    csType: "int",
  };
  static final MARSHAL_UINT64:CsTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "uint64_t",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    // csType: "ulong",
    primitive: true,
    csType: "long", // same as Haxe#5258?
  };
  static final MARSHAL_INT64:CsTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "int64_t",
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
    csType: "long",
  };

  static final MARSHAL_FLOAT32:CsTypeMarshal = {
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
    primitive: true,
    csType: "float",
  };
  static final MARSHAL_FLOAT64:CsTypeMarshal = {
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
    primitive: true,
    csType: "double",
  };

  // TODO: MarshalAs for strings? https://docs.microsoft.com/en-us/dotnet/standard/native-interop/type-marshaling
  static final MARSHAL_STRING:CsTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "const char*",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: false,
    csType: "string",
  };

  static final MARSHAL_BYTES:CsTypeMarshal = {
    haxeType: (macro : cs.system.IntPtr),
    l1Type: "uint8_t*",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)$l1;',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = (uint8_t*)$l2;',
    primitive: false,
    csType: "System.IntPtr",
  };

  public function new(library:CsLibrary) {
    super(library);
  }

  public function void():CsTypeMarshal return MARSHAL_VOID;

  public function bool():CsTypeMarshal return MARSHAL_BOOL;

  public function uint8():CsTypeMarshal return MARSHAL_UINT8;
  public function int8():CsTypeMarshal return MARSHAL_INT8;
  public function uint16():CsTypeMarshal return MARSHAL_UINT16;
  public function int16():CsTypeMarshal return MARSHAL_INT16;
  public function uint32():CsTypeMarshal return MARSHAL_UINT32;
  public function int32():CsTypeMarshal return MARSHAL_INT32;
  public function uint64():CsTypeMarshal return MARSHAL_UINT64;
  public function int64():CsTypeMarshal return MARSHAL_INT64;

  public function float32():CsTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CsTypeMarshal return MARSHAL_FLOAT64;

  public function string():CsTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():CsTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:CsTypeMarshal,
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
      public var ptr(default, null):cs.system.IntPtr;
      private var handle:cs.system.runtime.interopservices.GCHandle;
      public function unref():Void {
        if (bytes != null) {
          handle.Free();
          bytes = null;
          ptr = null;
          handle = null;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:cs.system.IntPtr, handle:cs.system.runtime.interopservices.GCHandle) {
        this.bytes = bytes;
        this.ptr = ptr;
        this.handle = handle;
      }
    }).fields;
    var pathBytesRef:TypePath = {
      name: tdefBytesRef.name,
      pack: tdefBytesRef.pack,
    };
    return {
      toBytesCopy: (self, size) -> macro {
        var _self:cs.system.IntPtr = $self;
        var _size:Int = $size;
        var _res:haxe.io.BytesData = new cs.NativeArray(_size);
        (@:privateAccess $e{library.fieldExpr("_ammer_cs_tobytescopy")})(_self, _size, _res, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $e{library.fieldExpr("_ammer_cs_frombytescopy")})(_bytes.getData(), _bytes.length);
      },

      toBytesRef: null,
      fromBytesRef: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        var handle = cs.system.runtime.interopservices.GCHandle.Alloc(
          _bytes.getData(),
          cs.system.runtime.interopservices.GCHandleType.Pinned
        );
        var ptr = handle.AddrOfPinnedObject();
        (@:privateAccess new $pathBytesRef(_bytes, ptr, handle));
      },
    };
  }

  function opaquePtrInternal(name:String):CsTypeMarshal return {
    haxeType: (macro : cs.system.IntPtr),
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
    primitive: false,
    csType: "System.IntPtr",
  };

  override function structPtrInternalFieldSetter(
    structName:String,
    type:CsTypeMarshal,
    field:BaseFieldRef<CsTypeMarshal>
  ):(self:Expr, val:Expr)->Expr {
    if (field.owned) {
      var fname = field.name;
      var code = 'int old_val = _arg0->${fname};
_arg0->${fname} = _arg1;
return old_val;';
      var name = library.mangleFunction(MARSHAL_INT32, [type, field.type], code);
      var nameNative = '${name}_internal';
      library.lb
        .ai('int ${nameNative}(')
        .a('${type.l1Type} _arg0, ${field.type.l1Type} _arg1')
        .al(") {")
        .i()
          .ail(code)
        .d()
        .al("}");
      library.lbImport
        .ai("[System.Runtime.InteropServices.DllImport(")
          // TODO: OS dependent
          .al('"${library.config.name}.dylib")]')
        .ai('public static extern int ${nameNative}(')
        .a("System.IntPtr arg0, int arg1")
        .al(");");
      library.lbImport
        .ai('public static void ${name}(')
        .a("System.IntPtr arg0, object arg1")
        .al(") {")
        .i()
          .ail("int handle_arg1 = _ammer_incref(arg1);")
          .ail('int handle_old = ${nameNative}(arg0, handle_arg1);')
          .ail("_ammer_decref(handle_old);")
        .d()
        .ail("}");
      library.tdef.fields.push({
        pos: library.config.pos,
        name: name,
        kind: FFun({
          ret: (macro : Void),
          expr: null,
          args: [{
            type: (macro : cs.system.IntPtr),
            name: "arg0",
          }, {
            type: (macro : Dynamic),
            name: "arg1",
          }],
        }),
        access: [APublic, AStatic, AExtern],
      });
      var setterF = library.fieldExpr(name);
      return (self, val) -> macro $setterF($self, $val);
    }
    return super.structPtrInternalFieldSetter(structName, type, field);
  }

  function haxePtrInternal(haxeType:ComplexType):CsTypeMarshal return {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "void*",
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: false,
    csType: "int",
  };

  function closureInternal(
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>
  ):CsTypeMarshal return {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "void*",
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_CONVERT_DIRECT,
    primitive: false,
    csType: "int",
  };
}

class Cs extends Base<
  CsConfig,
  CsLibraryConfig,
  CsTypeMarshal,
  CsLibrary,
  CsMarshalSet
> {
  public function new(config:CsConfig) {
    super("cs", config);
  }

  public function finalise():BuildProgram {
    for (lib in libraries) {
      lib.lb
        .ail('
int _ammer_init(void* delegates[${lib.delegateCtr}]) {
  _ammer_delegates = (void**)malloc(sizeof(void*) * ${lib.delegateCtr});
  memcpy(_ammer_delegates, delegates, sizeof(void*) * ${lib.delegateCtr});
  return 0;
}');
      lib.lbImport
        .ai("[System.Runtime.InteropServices.DllImport(")
          // TODO: OS dependent
          .al('"${lib.config.name}.dylib")]')
        .ail("public static extern int _ammer_init([System.Runtime.InteropServices.MarshalAs(")
          .a("System.Runtime.InteropServices.UnmanagedType.LPArray,")
          .a('SizeConst = ${lib.delegateCtr}')
          .a(")] System.IntPtr[] delegates);")
        .ail("static int _ammer_native = _ammer_init(new System.IntPtr[]{")
          .lmap([ for (idx in 0...lib.delegateCtr) idx ], (idx) ->
            // TODO: what even is this
            'System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate('
              + 'System.Delegate.CreateDelegate(typeof(ClosureDelegate${idx}), typeof(CoreExtern_example), "ImplClosureDelegate${idx}")),')
        .ail("});");
      lib.tdef.meta.push({
        pos: Context.currentPos(),
        params: [macro $v{lib.lbImport.done()}],
        name: ":classCode",
      });
    }
    return baseDynamicLinkProgram({});
  }
}

typedef CsConfig = BaseConfig;

@:allow(ammer.core.plat.Cs)
class CsLibrary extends BaseLibrary<
  CsLibrary,
  CsLibraryConfig,
  CsTypeMarshal,
  CsMarshalSet
> {
  var lbImport = new LineBuf();

  public function new(config:CsLibraryConfig) {
    super(config, new CsMarshalSet(this));
    tdef.meta.push({
      pos: config.pos,
      name: ":nativeGen",
    });
    lb
      .ail("void** _ammer_delegates;");
    // C# version of boilerplate
    lbImport
      .ail("static int _ammer_refctr = 1;")
      .ail("static System.Collections.Generic.Dictionary<object, int> _ammer_refs_handle "
        + "= new System.Collections.Generic.Dictionary<object, int>();")
      .ail("static System.Collections.Generic.Dictionary<object, int> _ammer_refs_counter "
        + "= new System.Collections.Generic.Dictionary<object, int>();")
      .ail("static System.Collections.Generic.Dictionary<int, object> _ammer_refs_reverse "
        + "= new System.Collections.Generic.Dictionary<int, object>();")
      .ail("private static int _ammer_incref(object val) {
  if (!_ammer_refs_handle.ContainsKey(val)) {
    _ammer_refs_handle[val] = _ammer_refctr;
    _ammer_refs_counter[val] = 1;
    _ammer_refs_reverse[_ammer_refctr] = val;
    return _ammer_refctr++;
  }
  _ammer_refs_counter[val]++;
  return _ammer_refs_handle[val];
}
private static void _ammer_decref(object val) {
  if (_ammer_refs_handle.ContainsKey(val)) {
    if (--_ammer_refs_counter[val] <= 0) {
      _ammer_refs_reverse.Remove(_ammer_refs_handle[val]);
      _ammer_refs_handle.Remove(val);
      _ammer_refs_counter.Remove(val);
    }
  }
}");
    lb.ail('
#include <inttypes.h>
void _ammer_cs_tobytescopy(uint8_t* data, int size, uint8_t* res, int res_size) {
  memcpy(res, data, size);
}
uint8_t* _ammer_cs_frombytescopy(uint8_t* data, int size) {
  uint8_t* res = (uint8_t*)malloc(size);
  memcpy(res, data, size);
  return res;
}
');
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .al('"${config.name}.dylib")]')
      .ail("public static extern void _ammer_cs_tobytescopy(System.IntPtr data, int size, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex = 3)] byte[] res, int res_size);");
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_cs_tobytescopy",
      kind: FFun({
        ret: (macro : Void),
        expr: null,
        args: [{
          type: (macro : cs.system.IntPtr),
          name: "data",
        }, {
          type: (macro : Int),
          name: "size",
        }, {
          type: (macro : haxe.io.BytesData),
          name: "res",
        }, {
          type: (macro : Int),
          name: "res_size",
        }],
      }),
      access: [APrivate, AStatic, AExtern],
    });
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .al('"${config.name}.dylib")]')
      .ail("public static extern System.IntPtr _ammer_cs_frombytescopy(byte[] data, int size);");
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_cs_frombytescopy",
      kind: FFun({
        ret: (macro : cs.system.IntPtr),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "data",
        }, {
          type: (macro : Int),
          name: "size",
        }],
      }),
      access: [APrivate, AStatic, AExtern],
    });
  }

  static function needsHandle(t:CsTypeMarshal):Bool {
    return t.l2ref == CsMarshalSet.MARSHAL_REGISTRY_REF;
  }

  public function addFunction(
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var needsHandles = args.exists(needsHandle) || needsHandle(ret);
    var name = mangleFunction(ret, args, code);
    var nameNative = needsHandles ? '${name}_internal' : name;
    lb
      .ai('${ret.l1Type} ${nameNative}(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_l1_arg_$idx', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != CsMarshalSet.MARSHAL_VOID)
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
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .a('"${config.name}.dylib", ')
        // TODO: send strings as byte arrays to avoid this...
        .a("CharSet = System.Runtime.InteropServices.CharSet.Ansi")
      .al(")]")
      .ai('public static extern ${ret.csType} ${nameNative}(')
      .mapi(args, (idx, arg) -> '${arg.csType} arg${idx}', ", ")
      .al(");");
    if (needsHandles) {
      var handleArgs = [ for (i in 0...args.length) if (needsHandle(args[i])) i ];
      lbImport
        .ai('public static ${needsHandle(ret) ? "object" : ret.csType} ${name}(')
        .mapi(args, (idx, arg) -> '${needsHandle(arg) ? "object" : arg.csType} arg${idx}', ", ")
        .al(") {")
        .i()
          .lmap(handleArgs, idx -> 'int handle_arg${idx} = _ammer_incref(arg${idx});')
          .ifi(needsHandle(ret))
            .ai('int handle_ret = ${nameNative}(')
            .mapi(args, (idx, arg) -> needsHandle(arg)
              ? 'handle_arg${idx}'
              : 'arg${idx}', ", ")
            .al(");")
            .lmap(handleArgs, idx -> '_ammer_decref(arg${idx});')
            .ail("return _ammer_refs_reverse[handle_ret];")
          .ife()
            .ai(ret == CsMarshalSet.MARSHAL_VOID ? "" : "return ")
            .a('${nameNative}(')
            .mapi(args, (idx, arg) -> needsHandle(arg)
              ? 'handle_arg${idx}'
              : 'arg${idx}', ", ")
            .al(");")
            .lmap(handleArgs, idx -> '_ammer_decref(arg${idx});')
          .ifd()
        .d()
        .ail("}");
    }
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: FFun({
        ret: needsHandle(ret) ? (macro : Dynamic) : ret.haxeType,
        expr: null,
        args: [ for (i => arg in args) {
          type: needsHandle(arg) ? (macro : Dynamic) : arg.haxeType,
          name: 'arg$i',
        } ],
      }),
      access: [APublic, AStatic, AExtern],
    });
    return fieldExpr(name);
  }

  var delegateCtr = 0;
  var delegates:Map<String, Int> = [];

  public function closureCall(
    fn:String,
    clType:MarshalClosure<CsTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    // TODO: use mangled as identifier instead of counter
    var delegateId = delegates[clType.type.mangled];
    if (delegateId == null) {
      delegates[clType.type.mangled] = (delegateId = delegateCtr++);
      lbImport
        .ai('private delegate ${clType.ret.csType} ClosureDelegate$delegateId(int handle_cl')
        .mapi(clType.args, (idx, arg) -> ', ${arg.csType} arg${idx}')
        .al(");");
      lbImport
        .ai('private static ${clType.ret.csType} ImplClosureDelegate$delegateId(int handle_cl')
        .mapi(clType.args, (idx, arg) -> ', ${arg.csType} arg${idx}')
        .al(") {")
        .i()
          .ail("object _cs_undef = global::haxe.lang.Runtime.undefined;")
          // TODO: handle refs for args (and ret) here as well?
          .ail("global::haxe.lang.Function cl = (global::haxe.lang.Function)_ammer_refs_reverse[handle_cl];")
          .ifi(clType.ret != CsMarshalSet.MARSHAL_VOID)
            .ai('return (${clType.ret.csType})')
          .ife()
            .ai("")
          .ifd()
          .a('cl.__hx_invoke${clType.args.length}_${clType.ret.primitive ? "f" : "o"}(')
          .mapi(clType.args, (idx, arg) -> clType.args[idx].primitive
            ? '(double)arg${idx}, _cs_undef'
            : '0.0, arg${idx}', ", ")
          .al(");")
        .d()
        .ail("}");
    }
    // TODO: ref/unref args?
    return new LineBuf()
      .ail("do {")
      .i()
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l3l2(arg, '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${clType.args[idx].l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ifi(clType.ret != CsMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l1Type} _l1_output;')
          .ail('_l1_output = ')
        .ifd()
        .i()
          .a('((${clType.ret.l1Type} (*)(int')
          .map(clType.args, arg -> ', ${arg.l1Type}')
          .a('))(_ammer_delegates[$delegateId]))($fn')
          .map(args, arg -> ', ${arg}')
          .a(');')
        .d()
        .ifi(clType.ret != CsMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ifi(ret != CsMarshalSet.MARSHAL_VOID)
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

typedef CsLibraryConfig = LibraryConfig;
typedef CsTypeMarshal = {
  >BaseTypeMarshal,
  primitive:Bool,
  csType:String,
};

#end
