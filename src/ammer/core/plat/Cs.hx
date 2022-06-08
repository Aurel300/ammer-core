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
  // The implementation is a noop but the identity of the function is used to
  // identify when ref/unref should happen in a C# wrapper.
  static final MARSHAL_REGISTRY_REF = (_:String) -> "";
  static final MARSHAL_REGISTRY_UNREF = (_:String) -> "";

  static function baseExtend(
    base:BaseTypeMarshal,
    ext:CsTypeMarshalExt,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):CsTypeMarshal {
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
      csType:    ext.csType,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshalSet.baseVoid(), {primitive: true, csType: "void"});
  public function void():CsTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshalSet.baseBool(), {primitive: true, csType: "bool"});
  public function bool():CsTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshalSet.baseUint8(), {primitive: true, csType: "byte"}, {
    arrayType: (macro : cs.types.UInt8),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshalSet.baseInt8(), {primitive: true, csType: "sbyte"}, {
    arrayType: (macro : cs.types.Int8),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshalSet.baseUint16(), {primitive: true, csType: "ushort"}, {
    arrayType: (macro : cs.types.UInt16),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshalSet.baseInt16(), {primitive: true, csType: "short"}, {
    arrayType: (macro : cs.types.Int16),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshalSet.baseUint32(), {
    // csType: "uint",
    primitive: true,
    csType: "int", // see Haxe#5258
  }, {
    arrayType: (macro : Int),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshalSet.baseInt32(), {primitive: true, csType: "int"}, {
    arrayType: (macro : Int),
  });
  static final MARSHAL_UINT64 = baseExtend(BaseMarshalSet.baseUint64(), {
    // csType: "ulong",
    primitive: true,
    csType: "long", // same as Haxe#5258?
  }, {
    // arrayType: (macro: cs.types.UInt64)
    arrayType: (macro: cs.types.Int64)
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshalSet.baseInt64(), {primitive: true, csType: "long"}, {
    arrayType: (macro : cs.types.Int64),
  });
  public function uint8():CsTypeMarshal return MARSHAL_UINT8;
  public function int8():CsTypeMarshal return MARSHAL_INT8;
  public function uint16():CsTypeMarshal return MARSHAL_UINT16;
  public function int16():CsTypeMarshal return MARSHAL_INT16;
  public function uint32():CsTypeMarshal return MARSHAL_UINT32;
  public function int32():CsTypeMarshal return MARSHAL_INT32;
  public function uint64():CsTypeMarshal return MARSHAL_UINT64;
  public function int64():CsTypeMarshal return MARSHAL_INT64;

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshalSet.baseFloat32(), {primitive: true, csType: "float"}, {
    arrayType: (macro : Single),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshalSet.baseFloat64(), {primitive: true, csType: "double"}, {
    arrayType: (macro : Float),
  });
  public function float32():CsTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CsTypeMarshal return MARSHAL_FLOAT64;

  // TODO: MarshalAs for strings? https://docs.microsoft.com/en-us/dotnet/standard/native-interop/type-marshaling
  static final MARSHAL_STRING = baseExtend(BaseMarshalSet.baseString(), {primitive: false, csType: "string"});
  public function string():CsTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshalSet.baseBytesInternal(), {primitive: false, csType: "System.IntPtr"}, {
    haxeType: (macro : cs.system.IntPtr),
    // l1l2: (l1, l2) -> '$l2 = (uint8_t*)$l1;',
    // l2l1: (l2, l1) -> '$l1 = (uint8_t*)$l2;',
  });
  function bytesInternalType():CsTypeMarshal return MARSHAL_BYTES;
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
      (macro : cs.system.IntPtr), macro null,
      (macro : cs.system.runtime.interopservices.GCHandle), macro null,
      macro handle.Free()
    );
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

  function opaquePtrInternal(name:String):CsTypeMarshal return baseExtend(BaseMarshalSet.baseOpaquePtrInternal(name), {
    primitive: false,
    csType: "System.IntPtr",
  }, {
    haxeType: (macro : cs.system.IntPtr),
  });

  function arrayPtrInternalType(element:CsTypeMarshal):CsTypeMarshal {
    var elType = element.arrayType != null ? element.arrayType : element.haxeType;
    return baseExtend(BaseMarshalSet.baseArrayPtrInternal(element), {
      primitive: false,
      csType: "System.IntPtr",
    }, {
      haxeType: (macro : cs.system.IntPtr),
    });
  }
  override function arrayPtrInternalOps(
    type:CsTypeMarshal,
    element:CsTypeMarshal,
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

    var copyTo = '_ammer_cs_toarraycopy_${element.mangled}';
    var copyFrom = '_ammer_cs_fromarraycopy_${element.mangled}';
    library.lb.ail('void $copyTo(uint8_t* data, int size, uint8_t* res, int res_size) {
  ${library.config.memcpyFunction}(res, data, size);
}
uint8_t* $copyFrom(uint8_t* data, int size) {
  uint8_t* res = (uint8_t*)${library.config.mallocFunction}(size);
  ${library.config.memcpyFunction}(res, data, size);
  return res;
}');
    library.lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .al('"${library.config.name}.dylib")]')
      .ail('public static extern void $copyTo(System.IntPtr data, int size, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex = 3)] ${element.csType}[] res, int res_size);');
    library.tdef.fields.push({
      pos: library.config.pos,
      name: copyTo,
      kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Int, cs.NativeArray<$elType>, Int) -> Void)),
      access: [APrivate, AStatic, AExtern],
    });
    library.lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .al('"${library.config.name}.dylib")]')
      .ail('public static extern System.IntPtr $copyFrom(${element.csType}[] data, int size);');
    library.tdef.fields.push({
      pos: library.config.pos,
      name: copyFrom,
      kind: TypeUtils.ffunCt((macro : (cs.NativeArray<$elType>, Int) -> cs.system.IntPtr)),
      access: [APrivate, AStatic, AExtern],
    });

    var pathArrayRef = baseArrayRef(
      element, vectorType,
      (macro : cs.system.IntPtr), macro null,
      (macro : cs.system.runtime.interopservices.GCHandle), macro null,
      macro handle.Free()
    );
    return {
      vectorType: vectorType,
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : cs.system.IntPtr);
        var _size = ($size : Int);
        var _ret = new cs.NativeArray<$elType>(_size);
        (@:privateAccess $e{library.fieldExpr(copyTo)})(
          _self,
          _size << $v{element.arrayBits},
          _ret,
          _size
        );
        haxe.ds.Vector.fromData(_ret);
      },
      fromHaxeCopy: (vector) -> macro {
        var _vector = ($vector : haxe.ds.Vector<$elType>);
        (@:privateAccess $e{library.fieldExpr(copyFrom)})(
          _vector.toData(),
          _vector.length << $v{element.arrayBits}
        );
      },

      toHaxeRef: null,
      fromHaxeRef: (vector) -> macro {
        var _vector = ($vector : haxe.ds.Vector<$elType>);
        var handle = cs.system.runtime.interopservices.GCHandle.Alloc(
          _vector.toData(),
          cs.system.runtime.interopservices.GCHandleType.Pinned
        );
        var ptr = handle.AddrOfPinnedObject();
        (@:privateAccess new $pathArrayRef(_vector, ptr, handle));
      },
    };
  }

  override function structPtrInternalFieldSetter(
    structName:String,
    type:CsTypeMarshal,
    field:BaseFieldRef<CsTypeMarshal>
  ):(self:Expr, val:Expr)->Expr {
    if (field.owned) {
      var fname = field.name;
      var code = 'int old_val = (int)_arg0->${fname};
_arg0->${fname} = (void*)(intptr_t)_arg1;
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
        kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Dynamic) -> Void)),
        access: [APublic, AStatic, AExtern],
      });
      var setterF = library.fieldExpr(name);
      return (self, val) -> macro $setterF($self, $val);
    }
    return super.structPtrInternalFieldSetter(structName, type, field);
  }

  function haxePtrInternal(haxeType:ComplexType):CsTypeMarshal return baseExtend(BaseMarshalSet.baseHaxePtrInternal(haxeType), {
    primitive: false,
    csType: "int",
  }, {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l1l2: BaseMarshalSet.MARSHAL_CONVERT_CAST("void*"),
    l2ref: MARSHAL_REGISTRY_REF,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: BaseMarshalSet.MARSHAL_CONVERT_CAST("int32_t"),
  });

  public function new(library:CsLibrary) {
    super(library);
  }
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
  _ammer_delegates = (void**)${lib.config.mallocFunction}(sizeof(void*) * ${lib.delegateCtr});
  ${lib.config.memcpyFunction}(_ammer_delegates, delegates, sizeof(void*) * ${lib.delegateCtr});
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
    lb.ail('void _ammer_cs_tobytescopy(uint8_t* data, int size, uint8_t* res, int res_size) {
  ${config.memcpyFunction}(res, data, size);
}
uint8_t* _ammer_cs_frombytescopy(uint8_t* data, int size) {
  uint8_t* res = (uint8_t*)${config.mallocFunction}(size);
  ${config.memcpyFunction}(res, data, size);
  return res;
}');
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        // TODO: OS dependent
        .al('"${config.name}.dylib")]')
      .ail("public static extern void _ammer_cs_tobytescopy(System.IntPtr data, int size, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex = 3)] byte[] res, int res_size);");
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_cs_tobytescopy",
      kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Int, haxe.io.BytesData, Int) -> Void)),
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
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData, Int) -> cs.system.IntPtr)),
      access: [APrivate, AStatic, AExtern],
    });
  }

  static function needsHandle(t:CsTypeMarshal):Bool {
    return t.l2ref == CsMarshalSet.MARSHAL_REGISTRY_REF;
  }

  public function addNamedFunction(
    name:String,
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    code:String,
    pos:Position
  ):Expr {
    var needsHandles = args.exists(needsHandle) || needsHandle(ret);
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
      kind: TypeUtils.ffun(
        args.map(arg -> needsHandle(arg) ? (macro : Dynamic) : arg.haxeType),
        needsHandle(ret) ? (macro : Dynamic) : ret.haxeType
      ),
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
          .ifi(clType.ret.mangled != "v")
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
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai('_l1_output = ')
        .ife()
          .ai("")
        .ifd()
        .a('((${clType.ret.l1Type} (*)(int32_t')
        .map(clType.args, arg -> ', ${arg.l1Type}')
        .a('))(_ammer_delegates[$delegateId]))((int32_t)$fn')
        .mapi(args, (idx, arg) ->
          clType.args[idx].l1Type == "int32_t" && clType.args[idx].l2Type == "void*"
          ? ', (int32_t)${arg}'
          : ', ${arg}')
        .al(');')
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

typedef CsLibraryConfig = LibraryConfig;
typedef CsTypeMarshalExt = {
  primitive:Bool,
  csType:String,
};
typedef CsTypeMarshal = {
  >BaseTypeMarshal,
  >CsTypeMarshalExt,
};

#end
