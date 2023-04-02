package ammer.core.plat;

#if macro

typedef CsConfig = BaseConfig;

typedef CsLibraryConfig = LibraryConfig;

typedef CsTypeMarshalExt = {
  primitive:Bool,
  csType:String,
  ?csTypeRet:String,
  ?l1Cs:(l1:String, cs:String)->String,
  ?csAnnotation:String,
};
typedef CsTypeMarshal = {
  >BaseTypeMarshal,
  >CsTypeMarshalExt,
};

class Cs extends Base<
  Cs,
  CsConfig,
  CsLibraryConfig,
  CsTypeMarshal,
  CsLibrary,
  CsMarshal
> {
  public function new(config:CsConfig) {
    super("cs", config);
  }

  public function createLibrary(libConfig:CsLibraryConfig):CsLibrary {
    return new CsLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({});
  }
}

@:allow(ammer.core.plat)
class CsLibrary extends BaseLibrary<
  CsLibrary,
  Cs,
  CsConfig,
  CsLibraryConfig,
  CsTypeMarshal,
  CsMarshal
> {
  var delegateCtr = 0;

  // TODO: move to base?
  var haxeRefTdefs:Map<String, TypeDefinition> = [];

  var lbImport = new LineBuf();
  var export:String;

  public function new(platform:Cs, config:CsLibraryConfig) {
    super(platform, config, new CsMarshal(this));
    tdef.meta.push({
      pos: config.pos,
      name: ":nativeGen",
    });
    export = '${config.language.match(Cpp | ObjectiveCpp) ? 'extern "C" ' : ""}_AMMER_LIB_EXPORT';
    lb
      .ail("void** _ammer_delegates;");
    lb.ail('$export void _ammer_cs_tohaxecopy(uint8_t* data, int size, uint8_t* res, int res_size) {
  ${config.memcpyFunction}(res, data, size);
}
$export uint8_t* _ammer_cs_fromhaxecopy(uint8_t* data, int size) {
  uint8_t* res = (uint8_t*)${config.mallocFunction}(size);
  ${config.memcpyFunction}(res, data, size);
  return res;
}');
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        .al('"${config.name}.dll")]')
      .ail("public static extern void _ammer_cs_tohaxecopy(System.IntPtr data, int size, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex = 3)] byte[] res, int res_size);");
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_cs_tohaxecopy",
      kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Int, haxe.io.BytesData, Int) -> Void)),
      access: [APrivate, AStatic, AExtern],
    });
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        .al('"${config.name}.dll")]')
      .ail("public static extern System.IntPtr _ammer_cs_fromhaxecopy(byte[] data, int size);");
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_cs_fromhaxecopy",
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData, Int) -> cs.system.IntPtr)),
      access: [APrivate, AStatic, AExtern],
    });
  }

  override function finalise(platConfig:CsConfig):Void {
    if (delegateCtr > 0) {
      lb
        .ail('
$export int _ammer_init(void* delegates[${delegateCtr}]) {
  _ammer_delegates = (void**)${config.mallocFunction}(sizeof(void*) * ${delegateCtr});
  ${config.memcpyFunction}(_ammer_delegates, delegates, sizeof(void*) * ${delegateCtr});
  return 0;
}');
      lbImport
        .ai('[System.Runtime.InteropServices.DllImport("${config.name}.dll")]')
        .ail("public static extern int _ammer_init([System.Runtime.InteropServices.MarshalAs(")
          .a("System.Runtime.InteropServices.UnmanagedType.LPArray,")
          .a('SizeConst = ${delegateCtr}')
          .a(")] System.IntPtr[] delegates);")
        .ail("static int _ammer_native = _ammer_init(new System.IntPtr[]{")
          .lmap([ for (idx in 0...delegateCtr) idx ], (idx) ->
            'System.Runtime.InteropServices.Marshal.GetFunctionPointerForDelegate('
              + 'System.Delegate.CreateDelegate(typeof(ClosureDelegate${idx}), typeof(CoreExtern_${config.name}), "ImplClosureDelegate${idx}")),')
        .ail("});");
    } else {
      lb.ail('
$export int _ammer_init(void) {
  return 0;
}');
      lbImport
        .ai('[System.Runtime.InteropServices.DllImport("${config.name}.dll")]')
        .ail("public static extern int _ammer_init();")
        .ail("static int _ammer_native = _ammer_init();");
    }
    tdef.meta.push({
      pos: Context.currentPos(),
      params: [macro $v{lbImport.done()}],
      name: ":classCode",
    });
    outputPathRelative = '${config.name}.dll';
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ai('$export ${ret.l1Type} $name(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
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
    //args.exists(arg -> arg.l1Cs != null);
    var wrapperNeeded = ret.l1Cs != null;
    var externName = name;
    var externRet = ret.csType;
    if (wrapperNeeded) {
      externName = '_extern_$name';
      externRet = ret.csTypeRet;
      lbImport
        .ai('public static ${ret.csType} $name(')
        .mapi(args, (idx, arg) -> '${arg.csType} arg${idx}', ", ")
        .al(") {")
        .i()
          .ai('${ret.csTypeRet} retL1 = $externName(')
          .mapi(args, (idx, arg) -> 'arg${idx}', ", ")
          .al(');')
          .ail('${ret.csType} ret;')
          .ail(ret.l1Cs("retL1", "ret"))
          .ail("return ret;")
        .d()
        .ail("}");
    }
    lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        .a('"${config.name}.dll", ')
        .a("CharSet = System.Runtime.InteropServices.CharSet.Ansi")
        .a(wrapperNeeded ? ', EntryPoint = "$name"' : "")
      .al(")]")
      .ai('public static extern $externRet $externName(')
      .mapi(args, (idx, arg) -> (arg.csAnnotation != null ? '${arg.csAnnotation} ' : "") + '${arg.csType} arg${idx}', ", ")
      .al(");");
    tdef.fields.push({
      pos: options.pos,
      name: name,
      kind: TypeUtils.ffun(
        args.map(arg -> arg.haxeType),
        ret.haxeType
      ),
      access: [APublic, AStatic, AExtern],
    });
    return fieldExpr(name);
  }

  function baseCall(
    lb:LineBuf,
    code:Expr,
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    outputExpr:String,
    argExprs:Array<String>
  ):Void {
    var delegateId = delegateCtr++;
    lbImport
      .ai('private delegate ${ret.csType} ClosureDelegate$delegateId(')
      .mapi(args, (idx, arg) -> '${arg.csType} arg${idx}', ", ")
      .al(");");
    var callArgs = [ for (i in 0...args.length) macro $i{'arg$i'} ];
    tdef.fields.push({
      pos: config.pos,
      name: 'ImplClosureDelegate$delegateId',
      kind: TypeUtils.ffun(
        args.map(arg -> arg.haxeType),
        ret.haxeType,
        code
      ),
      access: [APrivate, AStatic],
    });

    lb
      .ail("do {")
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l3l2(argExprs[idx], '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
        .ifi(ret.mangled != "v")
          .ail('${ret.l1Type} _l1_output;')
          .ai('_l1_output = ')
        .ife()
          .ai("")
        .ifd()
        .a('((${ret.l1Type} (*)(')
        .map(args, arg -> '${arg.l1Type}', ", ")
        .a('))(_ammer_delegates[$delegateId]))(')
        .mapi(args, (idx, arg) ->
          args[idx].l1Type == "int32_t" && args[idx].l2Type == "void*"
          ? '(int32_t)_l1_arg_${idx}'
          : '_l1_arg_${idx}', ", ")
        .al(');')
        .ifi(ret.mangled != "v")
          .ail('${ret.l2Type} _l2_output;')
          .ail(ret.l1l2("_l1_output", "_l2_output"))
          .ail(ret.l2l3("_l2_output", outputExpr))
        .ifd()
      .d()
      .al("} while (0);");
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<CsTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    var callArgs = [ for (i in 0...clType.args.length) macro $i{'arg${i + 1}'} ];
    var clAccess = TypeUtils.accessTdef(haxeRefTdefs[clType.type.mangled]);
    var adjArgs = [clType.type].concat(clType.args);
    var adjArgExprs = [fn].concat(args);
    return new LineBuf()
      .apply(baseCall.bind(_, macro {
        // TODO: handle refs for args (and ret)
        var arg0 = (@:privateAccess $clAccess.handles)[arg0].value;
        return arg0($a{callArgs});
      }, clType.ret, adjArgs, outputExpr, adjArgExprs))
      .done();
  }

  public function staticCall(
    ret:CsTypeMarshal,
    args:Array<CsTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    return new LineBuf()
      .apply(baseCall.bind(_, code, ret, args, outputExpr, argExprs))
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

@:allow(ammer.core.plat)
class CsMarshal extends BaseMarshal<
  CsMarshal,
  Cs,
  CsConfig,
  CsLibraryConfig,
  CsLibrary,
  CsTypeMarshal
> {
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
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
      primitive: ext.primitive,
      csType:    ext.csType,
      csTypeRet: ext.csTypeRet,
      l1Cs:      ext.l1Cs,
      csAnnotation: ext.csAnnotation,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid(), {primitive: true, csType: "void"});
  public function void():CsTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {primitive: true, csType: "bool"});
  public function bool():CsTypeMarshal return MARSHAL_BOOL;

  // TODO: using the correct `csType`s causes issues because the generated
  //       functions cannot be called with `Int` variables
  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {primitive: true, csType: "int" /*csType: "byte"*/}, {
    arrayType: (macro : cs.types.UInt8),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {primitive: true, csType: "int" /*csType: "sbyte"*/}, {
    arrayType: (macro : cs.types.Int8),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {primitive: true, csType: "int" /*csType: "ushort"*/}, {
    arrayType: (macro : cs.types.UInt16),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {primitive: true, csType: "int" /*csType: "short"*/}, {
    arrayType: (macro : cs.types.Int16),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    // csType: "uint",
    primitive: true,
    csType: "int", // see Haxe#5258
  }, {
    arrayType: (macro : Int),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {primitive: true, csType: "int"}, {
    arrayType: (macro : Int),
  });
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    // csType: "ulong",
    primitive: true,
    csType: "long", // same as Haxe#5258?
  }, {
    // arrayType: (macro: cs.types.UInt64)
    arrayType: (macro: cs.types.Int64)
  });
  static final MARSHAL_INT64 = baseExtend(BaseMarshal.baseInt64(), {primitive: true, csType: "long"}, {
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

  public function enumInt(name:String, type:CsTypeMarshal):CsTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {primitive: true, csType: type.csType});

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {primitive: true, csType: "float"}, {
    arrayType: (macro : Single),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {primitive: true, csType: "double"}, {
    arrayType: (macro : Float),
  });
  public function float32():CsTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CsTypeMarshal return MARSHAL_FLOAT64;

  // TODO: MarshalAs for strings? https://docs.microsoft.com/en-us/dotnet/standard/native-interop/type-marshaling
  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    primitive: false,
    csType: "string",

    // this is not great (currently the only reason for C#-side method wrappers ...)
    // see https://learn.microsoft.com/en-us/dotnet/framework/interop/marshalling-data-with-platform-invoke
    // TODO: can the type be IntPtr for both directions?
    csTypeRet: "System.IntPtr",
    l1Cs: (l1, cs) -> '$cs = System.Runtime.InteropServices.Marshal.PtrToStringAuto($l1);',
    // not available yet ...?
    // csAnnotation: "[System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPUTF8Str)]",
    csAnnotation: "[System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPStr)]",
  }, {
    // TODO: memory management for strings ...
    l2l3: (l2, l3) -> '$l3 = strdup($l2);',
  });
  public function string():CsTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {primitive: false, csType: "System.IntPtr"}, {
    haxeType: (macro : cs.system.IntPtr),
    // l1l2: (l1, l2) -> '$l2 = (uint8_t*)$l1;',
    // l2l1: (l2, l1) -> '$l1 = (uint8_t*)$l2;',
  });
  function bytesInternalType():CsTypeMarshal return MARSHAL_BYTES;
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
      (macro : cs.system.IntPtr), macro null,
      (macro : cs.system.runtime.interopservices.GCHandle), macro null,
      macro handle.Free()
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self:cs.system.IntPtr = $self;
        var _size:Int = $size;
        var _res:haxe.io.BytesData = new cs.NativeArray(_size);
        (@:privateAccess $e{library.fieldExpr("_ammer_cs_tohaxecopy")})(_self, _size, _res, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $e{library.fieldExpr("_ammer_cs_fromhaxecopy")})(_bytes.getData(), _bytes.length);
      },

      toHaxeRef: null,
      fromHaxeRef: (bytes) -> macro {
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

  function opaqueInternal(name:String):CsTypeMarshal return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
    primitive: false,
    csType: "System.IntPtr",
  }, {
    haxeType: (macro : cs.system.IntPtr),
  });

  function structPtrDerefInternal(name:String):CsTypeMarshal {
    return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
      primitive: false,
      csType: "System.IntPtr",
    }, {
      haxeType: (macro : cs.system.IntPtr),
    });
  }

  function arrayPtrInternalType(element:CsTypeMarshal):CsTypeMarshal {
    var elType = element.arrayType != null ? element.arrayType : element.haxeType;
    return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
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
        .al('"${library.config.name}.dll")]')
      .ail('public static extern void $copyTo(System.IntPtr data, int size, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPArray, SizeParamIndex = 3)] ${element.csType}[] res, int res_size);');
    library.tdef.fields.push({
      pos: library.config.pos,
      name: copyTo,
      kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Int, cs.NativeArray<$elType>, Int) -> Void)),
      access: [APrivate, AStatic, AExtern],
    });
    library.lbImport
      .ai("[System.Runtime.InteropServices.DllImport(")
        .al('"${library.config.name}.dll")]')
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

  /*
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
          .al('"${library.config.name}.dll")]')
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
  */
  /*
  override function arrayPtrInternalSetter(
    type:CsTypeMarshal,
    element:CsTypeMarshal
  ):(self:Expr, index:Expr, val:Expr)->Expr {
    if (owned) {
      var code = 'int old_val = (int)_arg0[_arg1];
_arg0[_arg1] = (void*)(intptr_t)_arg2;
return old_val;';
      var name = library.mangleFunction(MARSHAL_INT32, [type, MARSHAL_INT32, element], code);
      var nameNative = '${name}_internal';
      library.lb
        .ai('int ${nameNative}(')
        .a('void** _arg0, int _arg1, ${element.l1Type} _arg2')
        .al(") {")
        .i()
          .ail(code)
        .d()
        .al("}");
      library.lbImport
        .ai("[System.Runtime.InteropServices.DllImport(")
          .al('"${library.config.name}.dll")]')
        .ai('public static extern int ${nameNative}(')
        .a("System.IntPtr arg0, int arg1, int arg2")
        .al(");");
      library.lbImport
        .ai('public static void ${name}(')
        .a("System.IntPtr arg0, int arg1, object arg2")
        .al(") {")
        .i()
          .ail("int handle_arg2 = _ammer_incref(arg2);")
          .ail('int handle_old = ${nameNative}(arg0, arg1, handle_arg2);')
          .ail("_ammer_decref(handle_old);")
        .d()
        .ail("}");
      library.tdef.fields.push({
        pos: library.config.pos,
        name: name,
        kind: TypeUtils.ffunCt((macro : (cs.system.IntPtr, Int, Dynamic) -> Void)),
        access: [APublic, AStatic, AExtern],
      });
      var setterF = library.fieldExpr(name);
      return (self, index, val) -> macro $setterF($self, $index, $val);
    }
    return super.arrayPtrInternalSetter(type, element, owned);
  }
*/

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<CsTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : Int),
      macro 0,
      macro handles[handle].value,
      macro handles[handle].count,
      rc -> macro handles[handle].count = $rc,
      value -> macro {
        var h = handleCtr++; // TODO: atomic?
        handles[h] = {value: $value, count: 0};
        h;
      },
      macro handles.remove(handle),
      (macro class {
        static var handles:Map<Int, {value:$haxeType, count:Int}> = [];
        static var handleCtr = 1; // TODO: overflow
      }).fields
    );
    library.haxeRefTdefs[ret.mangled] = ret.tdef;
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):CsTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    primitive: false, // ?
    csType: "int",
  }, {
    haxeType: (macro : Int),
    l1Type: "int32_t",
    l1l2: BaseMarshal.MARSHAL_CONVERT_INT_TO_PTR,
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("int32_t"),
  });

  public function new(library:CsLibrary) {
    super(library);
  }
}

#end
