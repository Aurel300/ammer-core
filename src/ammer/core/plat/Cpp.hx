package ammer.core.plat;

#if macro

@:structInit
class CppConfig extends BaseConfig {
  public var staticLink:Bool = true;
}

typedef CppLibraryConfig = LibraryConfig;

typedef CppTypeMarshal = BaseTypeMarshal;

class Cpp extends Base<
  Cpp,
  CppConfig,
  CppLibraryConfig,
  CppTypeMarshal,
  CppLibrary,
  CppMarshal
> {
  public function new(config:CppConfig) {
    super("cpp-static", config);
    if (!config.staticLink) throw "todo";
  }

  public function createLibrary(libConfig:CppLibraryConfig):CppLibrary {
    return new CppLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    // C++ does not use `ammer.buildPath`. It uses the compiler output path
    // (`--cpp the/path/here`), to make it easy for `@:headerCode` to include
    // header with relative paths during `hxcpp` compilation.
    var outputPath = haxe.macro.Compiler.getOutput();

    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.language.extension();
      var exth = lib.config.language.extensionHeader();
      ops.push(BOAlways(File('${outputPath}/ammer_build/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));

      ops.push(BOAlways(
        File('${outputPath}/${lib.headerPath}'),
        WriteContent(lib.lbHeader.done())
      ));
      ops.push(BOAlways(
        File('${outputPath}/${lib.codePath}'),
        WriteContent(lib.lb.done())
      ));
    }
    return new BuildProgram(ops);
  }
}

@:allow(ammer.core.plat)
class CppLibrary extends BaseLibrary<
  CppLibrary,
  Cpp,
  CppConfig,
  CppLibraryConfig,
  CppTypeMarshal,
  CppMarshal
> {
  var lbHeader = new LineBuf();
  var definedNativeTypes:Map<String, ComplexType> = [];
  var haxeRefCt:ComplexType = null;

  var headerPath:String;
  var codePath:String;

  function defineNativeType(name:String):ComplexType {
    // TODO: is there a better way to turn the type into cpp.Pointers?
    var pointerWrap = false;
    if (name.endsWith("*")) {
      // we only do this once, we want void** -> cpp.Pointer<void*>
      pointerWrap = true;
      name = name.substr(0, name.length - 1);
    }

    var ret = definedNativeTypes[name];
    if (ret == null) {
      var native = typeDefCreate(false);
      native.name = '${config.typeDefName}_Native_${Mangle.identifier(name)}';
      native.isExtern = true;
      native.meta = [{
        pos: config.pos,
        params: [macro $v{name}],
        name: ":native",
      }];
      addCppIncludes(native, false);
      TypeUtils.defineType(native);
      definedNativeTypes[name] = ret = TPath({
        pack: config.typeDefPack,
        name: native.name,
      });
    }

    return pointerWrap ? (macro : cpp.Pointer<$ret>) : ret;
  }

  function pushNative(name:String, native:String, signature:ComplexType, pos:Position, pub:Bool = false):Void {
    tdef.fields.push({
      pos: pos,
      name: name,
      meta: [{
        pos: pos,
        params: [macro $v{native}],
        name: ":native",
      }],
      kind: TypeUtils.ffunCt(signature, macro throw 0),
      access: [pub ? APublic : APrivate, AStatic],
    });
  }

  function outputRelativePath(pack:Array<String>, target:String):String {
    // an extra `../` for `src` or `include`
    return pack.map(part -> "../").join("") + "../" + target;
  }

  public function addCppIncludes(tdef:TypeDefinition, code:Bool):Void {
    tdef.meta.push({
      pos: config.pos,
      params: [macro $v{"#include \"" + outputRelativePath(tdef.pack, headerPath) + "\""}],
      name: ":headerCode",
    });
    if (code) {
      var fileCode = new LineBuf();
      for (define in config.definesCodeOnly) {
        fileCode.ail('#define $define');
      }
      fileCode.ail("#include \"" + outputRelativePath(tdef.pack, codePath) + "\"");
      tdef.meta.push({
        pos: config.pos,
        params: [macro $v{fileCode.done()}],
        name: ":cppFileCode",
      });
    }
  }

  public function new(platform:Cpp, config:CppLibraryConfig) {
    super(platform, config, new CppMarshal(this));

    var exth = config.language.extensionHeader();
    var ext = config.language.extension();
    headerPath = 'ammer_build/${config.name}/lib.cpp_static.$exth';
    codePath = 'ammer_build/${config.name}/lib.cpp_static.$ext';

    addCppIncludes(tdef, true);
    tdefStaticCallbacks.meta.push({
      pos: config.pos,
      name: ":unreflective",
    });
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_haxe_scb",
      kind: FVar(TPath({
        pack: tdefStaticCallbacks.pack,
        name: tdefStaticCallbacks.name,
      }), macro null),
      access: [APrivate, AStatic],
    });

    // TODO: share type across libraries?
    var native = typeDefCreate(false);
    native.name = '${config.typeDefName}_NativeHaxeRef';
    native.isExtern = true;
    native.meta = [{
      pos: config.pos,
      params: [macro "_ammer_haxe_ref"],
      name: ":native",
    }, {
      pos: config.pos,
      name: ":structAccess",
    }];
    native.fields = [{
      pos: config.pos,
      name: "refcount",
      kind: FVar((macro : Int)),
      access: [APrivate],
    }, {
      pos: config.pos,
      name: "value",
      kind: FVar((macro : Any)),
      access: [APrivate],
    }];
    addCppIncludes(native, false);
    TypeUtils.defineType(native);

    haxeRefCt = TPath({
      params: [TPType(TPath({
        pack: config.typeDefPack,
        name: native.name,
      }))],
      pack: ["cpp"],
      name: "Pointer", // Star?
    });

    pushNative("_ammer_ref_create", '_ammer_ref_${config.name}_create', (macro : (Dynamic) -> $haxeRefCt), config.pos);
    pushNative("_ammer_ref_delete", '_ammer_ref_${config.name}_delete', (macro : ($haxeRefCt) -> Void), config.pos);

    lbHeader.ail('
#pragma once
#ifndef _AMMER_CORE_HAXE_REF
#define _AMMER_CORE_HAXE_REF 1
typedef struct { ::Dynamic value; int32_t refcount; } _ammer_haxe_ref;
_ammer_haxe_ref* _ammer_ref_${config.name}_create(::Dynamic value);
void _ammer_ref_${config.name}_delete(_ammer_haxe_ref* ref);
#endif');
    lb.ail('
#include <${tdefStaticCallbacks.pack.map(p -> '$p/').join("")}${tdefStaticCallbacks.name}.h>
_ammer_haxe_ref* _ammer_ref_${config.name}_create(::Dynamic value) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = value;
  ref->refcount = 0;
  ::hx::GCAddRoot((hx::Object**)&ref->value);
  return ref;
}
void _ammer_ref_${config.name}_delete(_ammer_haxe_ref* ref) {
  ::hx::GCRemoveRoot((hx::Object**)&ref->value);
  ref->value = nullptr;
  ${config.freeFunction}(ref);
}');
  }

  override function finalise(platConfig:CppConfig):Void {
    // TODO: file dependency to trigger recompilation when stubs change

    // This is kept in a separate meta with a comment tag to allow `ammer` to
    // rewrite it when baking libraries.
    var buildXmlPaths = new LineBuf()
      .ail('<!--ammer_core_paths:${config.name}--><files id="haxe">').i()
        .lmap(config.includePaths, path -> '<compilerflag value="-I$path"/>')
      .d().ail('</files>')
      .ail('<target id="haxe">').i()
        .lmap(config.libraryPaths, path -> '<libpath name="$path"/>')
      .d().ail("</target>")
      .done();
    tdef.meta.push({
      name: ":buildXml",
      params: [{expr: EConst(CString(buildXmlPaths)), pos: config.pos}],
      pos: config.pos
    });

    var buildXml = new LineBuf()
      .ail('<files id="haxe">').i()
        .lmap(config.defines, name -> '<compilerflag value="-D$name"/>')
      .d().ail("</files>")
      .ail('<target id="haxe">').i()
        .lmap(config.linkNames, name -> '<lib name="-l$name" unless="windows" />')
        .lmap(config.linkNames, name -> '<lib name="$name" if="windows" />')
        // TODO: allow only on Mac
        .lmap(config.frameworks, name -> '<flag value="-framework" /><flag value="$name" />')
      .d().ail("</target>")
      .done();
    tdef.meta.push({
      name: ":buildXml",
      params: [{expr: EConst(CString(buildXml)), pos: config.pos}],
      pos: config.pos
    });

    super.finalise(platConfig);
    outputPathRelative = null;
  }

  override public function addInclude(include:SourceInclude):Void {
    super.addInclude(include);
    lbHeader.ail(include.toCode());
  }

  override public function addHeaderCode(code:String):Void {
    lbHeader.ail(code);
  }

  public function addNamedFunction(
    name:String,
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ai('${ret.l1Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_$idx', ", ")
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
    lbHeader
      .ai('${ret.l1Type} ${name}(')
      .map(args, arg -> arg.l1Type, ", ")
      .a(args.length == 0 ? "void" : "")
      .al(");");
    pushNative(name, name, TFunction(args.map(arg -> arg.haxeType), ret.haxeType), options.pos, true);
    return fieldExpr(name);
  }

  function baseCall(
    lb:LineBuf,
    call:String,
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    outputExpr:String,
    argExprs:Array<String>
  ):Void {
    lb
      .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l3l2(argExprs[idx], '_l2_arg_$idx'))
      .lmapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l2l1('_l2_arg_$idx', '_l1_arg_$idx'))
      .ifi(ret.mangled != "v")
        .ail('${ret.l1Type} _l1_output;')
        .ai('_l1_output = (${ret.l1Type})($call(')
      .ife()
        .ai('(${ret.l1Type})($call(')
      .ifd()
      .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
      .al("));")
      .ifi(ret.mangled != "v")
        .ail('${ret.l2Type} _l2_output;')
        .ail(ret.l1l2("_l1_output", "_l2_output"))
        .ail(ret.l2l3("_l2_output", outputExpr))
      .ifd();
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<CppTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    return new LineBuf()
      .ail("do {")
      .i()
        .ail('${clType.type.l2Type} _l2_fn;')
        .ail(clType.type.l3l2(fn, "_l2_fn"))
        .ail("_ammer_haxe_ref* _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("::Dynamic _l1_fn;")
        .ail("_l1_fn = _l1_fn_ref->value;")
        .apply(baseCall.bind(_, "_l1_fn", clType.ret, clType.args, outputExpr, args))
      .d()
      .ail("} while (0);")
      .done();
  }

  public function staticCall(
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    var name = baseStaticCall(ret, args, code);
    return new LineBuf()
      .ail("do {")
      .i()
        .apply(baseCall.bind(
          _, "::" + tdefStaticCallbacks.pack.concat([tdefStaticCallbacks.name + "_obj", name]).join("::"), ret, args, outputExpr, argExprs
        ))
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail("::hx::NativeAttach _cpp_attach_gc;")
        .ifi(ret.mangled != "v")
          .ail('${ret.l3Type} ${config.returnIdent};')
        .ifd()
        .ail(code)
        .ifi(ret.mangled != "v")
          .ail('return ${config.returnIdent};')
        .ifd()
      .d()
      .al("}");
    return name;
  }
}

@:allow(ammer.core.plat)
class CppMarshal extends BaseMarshal<
  CppMarshal,
  Cpp,
  CppConfig,
  CppLibraryConfig,
  CppLibrary,
  CppTypeMarshal
> {
  static function baseExtend(
    base:BaseTypeMarshal,
    over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):CppTypeMarshal {
    return {
      haxeType:  over.haxeType  != null ? over.haxeType  : base.haxeType,
      l1Type:    over.l1Type    != null ? over.l1Type    : base.l1Type,
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

  static final MARSHAL_VOID = BaseMarshal.baseVoid();
  public function void():CppTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = BaseMarshal.baseBool();
  public function bool():CppTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8  = baseExtend(BaseMarshal.baseUint8(),  {arrayType: (macro : cpp.UInt8) });
  static final MARSHAL_INT8   = baseExtend(BaseMarshal.baseInt8(),   {arrayType: (macro : cpp.Int8)  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {arrayType: (macro : cpp.UInt16)});
  static final MARSHAL_INT16  = baseExtend(BaseMarshal.baseInt16(),  {arrayType: (macro : cpp.Int16) });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {arrayType: (macro : cpp.UInt32)});
  static final MARSHAL_INT32  = baseExtend(BaseMarshal.baseInt32(),  {arrayType: (macro : cpp.Int32) });
  public function uint8():CppTypeMarshal return MARSHAL_UINT8;
  public function int8():CppTypeMarshal return MARSHAL_INT8;
  public function uint16():CppTypeMarshal return MARSHAL_UINT16;
  public function int16():CppTypeMarshal return MARSHAL_INT16;
  public function uint32():CppTypeMarshal return MARSHAL_UINT32;
  public function int32():CppTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {arrayType: (macro : cpp.UInt64)});
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(),  {arrayType: (macro : cpp.Int64) });
  public function uint64():CppTypeMarshal return MARSHAL_UINT64;
  public function int64():CppTypeMarshal return MARSHAL_INT64;

  // setting `haxeType` to a type defined with `defineNativeType(name)` would
  // result in the type being represented more "cleanly" in C++, but then it
  // would not as easily be assignable to/from integers
  public function enumInt(name:String, type:CppTypeMarshal):CppTypeMarshal
    return baseExtend(BaseMarshal.baseEnumInt(name, type), {});

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {arrayType: (macro : cpp.Float32)});
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {arrayType: (macro : cpp.Float64)});
  public function float32():CppTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CppTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    l1Type: "::String",
  });
  public function string():CppTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : cpp.Pointer<cpp.UInt8>),
  });
  function bytesInternalType():CppTypeMarshal return MARSHAL_BYTES;
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
      (macro : cpp.Pointer<cpp.UInt8>), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        var _ret = haxe.io.Bytes.alloc(_size); // TODO: does this zero unnecessarily?
        if (_size != 0) { // hxcpp#1028
          $e{blit(
            macro _self, macro 0,
            macro cpp.Pointer.ofArray(_ret.getData()), macro 0,
            macro _size
          )};
        }
        _ret;
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = $e{alloc(macro _bytes.length)};
        $e{blit(
          macro cpp.Pointer.ofArray(_bytes.getData()), macro 0,
          macro _ret, macro 0,
          macro _bytes.length
        )};
        _ret;
      },

      toHaxeRef: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        haxe.io.Bytes.ofData(_self.toUnmanagedArray(_size));
      },
      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr = cpp.Pointer.ofArray(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr, 0));
      },
    };
  }

  function opaqueInternal(name:String):CppTypeMarshal return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
    haxeType: library.defineNativeType(name),
    l1Type: (if (name.endsWith("*")) {
      '::cpp::Pointer<${name.substr(0, name.length - 1)}>';
    } else null),
  });

  function structPtrDerefInternal(name:String):CppTypeMarshal return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
    haxeType: library.defineNativeType('$name*'),
    l1Type: '::cpp::Pointer<$name>',
  });

  function arrayPtrInternalType(element:CppTypeMarshal):CppTypeMarshal {
    var elType = element.arrayType != null ? element.arrayType : element.haxeType;
    return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
      haxeType: (macro : cpp.Pointer<$elType>),
    });
  }
  override function arrayPtrInternalOps(
    type:CppTypeMarshal,
    element:CppTypeMarshal,
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
    var pathArrayRef = baseArrayRef(
      element, vectorType,
      (macro : cpp.Pointer<$elType>), macro null,
      (macro : Int), macro 0, // handle unused
      macro {}
    );
    return {
      vectorType: vectorType,
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<$elType>);
        var _size = ($size : Int);
        haxe.ds.Vector.fromData(_self.toUnmanagedArray(_size)).copy();
      },
      fromHaxeCopy: (vector) -> macro {
        var _vector = (cast $vector : $vectorType);
        var _data:cpp.Pointer<$elType> = cpp.Pointer.ofArray(_vector.toData());
        // TODO: use alloc and blit instead?
        var _ret:cpp.Star<$elType> = cpp.Native.malloc(_vector.length << $v{element.arrayBits});
        cpp.Native.memcpy(_ret, _data, _vector.length << $v{element.arrayBits});
        cpp.Pointer.fromStar(_ret);
      },
      toHaxeRef: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<$elType>);
        var _size = ($size : Int);
        haxe.ds.Vector.fromData(_self.toUnmanagedArray(_size));
      },
      fromHaxeRef: (vector) -> macro {
        var _vector = (cast $vector : $vectorType);
        var _ptr = cpp.Pointer.ofArray(_vector.toData());
        (@:privateAccess new $pathArrayRef(_vector, _ptr, 0));
      },
    };
  }

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<CppTypeMarshal> {
    var res = baseHaxePtrInternal(
      haxeType,
      library.haxeRefCt,
      macro null,
      macro @:privateAccess handle.ref.value,
      macro @:privateAccess handle.ref.refcount,
      rc -> macro @:privateAccess handle.ref.refcount = $rc,
      value -> macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_create")})($value),
      macro (@:privateAccess $e{library.fieldExpr("_ammer_ref_delete")})(handle)
    );
    library.addCppIncludes(res.tdef, false);
    TypeUtils.defineType(res.tdef);
    return res.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):CppTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: library.haxeRefCt,
    arrayType: (macro : cpp.Star<cpp.Void>),
    l1l2: BaseMarshal.MARSHAL_CONVERT_CAST("void*"),
    l2l1: BaseMarshal.MARSHAL_CONVERT_CAST("_ammer_haxe_ref*"),
  });

  public function new(library:CppLibrary) {
    super(library);
  }
}

#end
