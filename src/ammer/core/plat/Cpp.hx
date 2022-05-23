package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

@:allow(ammer.core.plat.Cpp)
class CppMarshalSet extends BaseMarshalSet<
  CppMarshalSet,
  CppLibraryConfig,
  CppLibrary,
  CppTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

  // TODO: ${config.internalPrefix}
  static final MARSHAL_REGISTRY_GET_NODE = (l1:String, l2:String)
    -> '$l2 = _ammer_core_registry_get($l1.mPtr);';
  static final MARSHAL_REGISTRY_REF = (l2:String)
    -> '_ammer_core_registry_incref($l2);';
  static final MARSHAL_REGISTRY_UNREF = (l2:String)
    -> '_ammer_core_registry_decref($l2);';
  static final MARSHAL_REGISTRY_GET_KEY = (l2:String, l1:String) // TODO: target type cast
    -> '$l1 = $l2->key;';

  static final MARSHAL_VOID:CppTypeMarshal = {
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
  };

  static final MARSHAL_BOOL:CppTypeMarshal = {
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
  };

  static final MARSHAL_UINT8:CppTypeMarshal = {
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
  };
  static final MARSHAL_INT8:CppTypeMarshal = {
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
  };
  static final MARSHAL_UINT16:CppTypeMarshal = {
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
  };
  static final MARSHAL_INT16:CppTypeMarshal = {
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
  };
  static final MARSHAL_UINT32:CppTypeMarshal = {
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
  };
  static final MARSHAL_INT32:CppTypeMarshal = {
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
  };
  static final MARSHAL_UINT64:CppTypeMarshal = {
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
  };
  static final MARSHAL_INT64:CppTypeMarshal = {
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
  };

  static final MARSHAL_FLOAT32:CppTypeMarshal = {
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
  };
  static final MARSHAL_FLOAT64:CppTypeMarshal = {
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
  };

  static final MARSHAL_STRING:CppTypeMarshal = {
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
  };

  static final MARSHAL_BYTES:CppTypeMarshal = {
    haxeType: (macro : cpp.Pointer<cpp.UInt8>),
    l1Type: "uint8_t*",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
  }

  public function new(library:CppLibrary) {
    super(library);
  }

  public function void():CppTypeMarshal return MARSHAL_VOID;

  public function bool():CppTypeMarshal return MARSHAL_BOOL;

  public function uint8():CppTypeMarshal return MARSHAL_UINT8;
  public function int8():CppTypeMarshal return MARSHAL_INT8;
  public function uint16():CppTypeMarshal return MARSHAL_UINT16;
  public function int16():CppTypeMarshal return MARSHAL_INT16;
  public function uint32():CppTypeMarshal return MARSHAL_UINT32;
  public function int32():CppTypeMarshal return MARSHAL_INT32;
  public function uint64():CppTypeMarshal return MARSHAL_UINT64;
  public function int64():CppTypeMarshal return MARSHAL_INT64;

  public function float32():CppTypeMarshal return MARSHAL_FLOAT32;
  public function float64():CppTypeMarshal return MARSHAL_FLOAT64;

  public function string():CppTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():CppTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:CppTypeMarshal,
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
      public var ptr(default, null):cpp.Pointer<cpp.UInt8>;
      public function unref():Void {
        if (bytes != null) {
          // TODO: is this sufficient to also prevent the bytes buffer moving?
          bytes = null;
          ptr = null;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:cpp.Pointer<cpp.UInt8>) {
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
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        var _ret = haxe.io.Bytes.alloc(_size); // TODO: does this zero unnecessarily?
        $e{blit(
          macro _self, macro 0,
          macro cpp.Pointer.ofArray(_ret.getData()), macro 0,
          macro _size
        )};
        _ret;
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = $e{alloc(macro _bytes.length)};
        $e{blit(
          macro cpp.Pointer.ofArray(_bytes.getData()), macro 0,
          macro _ret, macro 0,
          macro _bytes.length
        )};
        _ret;
      },

      toBytesRef: (self, size) -> macro {
        var _self = ($self : cpp.Pointer<cpp.UInt8>);
        var _size = ($size : Int);
        haxe.io.Bytes.ofData(_self.toUnmanagedArray(_size));
      },
      fromBytesRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ptr = cpp.Pointer.ofArray(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ptr));
      },
    };
  }

  function opaquePtrInternal(name:String):CppTypeMarshal {
    var native = library.typeDefCreate();
    native.name = '${library.config.typeDefName}_Native_${Mangle.identifier(name)}';
    native.isExtern = true;
    native.meta = [{
      pos: library.config.pos,
      params: [macro $v{name}],
      name: ":native",
    }];
    library.nativeTypes[name] = {
      tdef: native,
      fields: new Map(),
    };
    return {
      haxeType: TPath({
        params: [TPType(TPath({
          pack: library.config.typeDefPack,
          name: native.name,
        }))],
        pack: ["cpp"],
        name: "Pointer", // Star?
      }),
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
    };
  }

  // test of direct getter/setter optimisation
  /*
  override function structPtrInternalFieldGetter(
    structName:String,
    type:CppTypeMarshal,
    field:BaseFieldRef<CppTypeMarshal>
  ):(self:Expr)->Expr {
    return (switch (field.type) {
      case MARSHAL_VOID
      | MARSHAL_BOOL
      | MARSHAL_UINT8
      | MARSHAL_INT8
      | MARSHAL_UINT16
      | MARSHAL_INT16
      | MARSHAL_UINT32
      | MARSHAL_INT32
      | MARSHAL_UINT64
      | MARSHAL_INT64
      | MARSHAL_FLOAT32
      | MARSHAL_FLOAT64:
        var fname = field.name;
        var haxeType = field.type.haxeType;
        /*
        if (!library.nativeTypes[structName].fields.exists(fname)) {
          library.nativeTypes[structName].tdef.fields.push({
            pos: library.config.pos,
            name: fname,
            kind: FVar(field.type.haxeType, null),
            access: [APublic],
          });
          library.nativeTypes[structName].fields[fname] = true;
        }
        (self) -> macro ((@:privateAccess $self.ref.$fname) : $haxeType);
        * /
        var syntax = '{0}.$fname';
        (self) -> macro ((untyped __cpp__($v{syntax}, $self.ref)) : $haxeType);
      case _: super.structPtrInternalFieldGetter(structName, type, field);
    });
  }

  override function structPtrInternalFieldSetter(
    structName:String,
    type:CppTypeMarshal,
    field:BaseFieldRef<CppTypeMarshal>
  ):(self:Expr, val:Expr)->Expr {
    return (switch (field.type) {
      case MARSHAL_VOID
      | MARSHAL_BOOL
      | MARSHAL_UINT8
      | MARSHAL_INT8
      | MARSHAL_UINT16
      | MARSHAL_INT16
      | MARSHAL_UINT32
      | MARSHAL_INT32
      | MARSHAL_UINT64
      | MARSHAL_INT64
      | MARSHAL_FLOAT32
      | MARSHAL_FLOAT64:
        var fname = field.name;
        var haxeType = field.type.haxeType;
        /*
        if (!library.nativeTypes[structName].fields.exists(fname)) {
          library.nativeTypes[structName].tdef.fields.push({
            pos: library.config.pos,
            name: fname,
            kind: FVar(field.type.haxeType, null),
            access: [APublic],
          });
          library.nativeTypes[structName].fields[fname] = true;
        }
        (self, val) -> macro (if (true) { $self.ref.$fname = ($val : $haxeType); } : Void);
        * /
        var syntax = '{0}.$fname = {1}';
        (self, val) -> macro ((untyped __cpp__($v{syntax}, $self.ref, ($val : $haxeType))) : Void);
      case _: super.structPtrInternalFieldSetter(structName, type, field);
    });
  }
  */

  function haxePtrInternal(haxeType:ComplexType):CppTypeMarshal return {
    haxeType: (macro : Dynamic),
    l1Type: "::Dynamic",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: (l3, l2) -> '$l2 = (${library.config.internalPrefix}registry_node*)$l3;',
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };

  function closureInternal(
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>
  ):CppTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "::Dynamic",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: (l3, l2) -> '$l2 = (${library.config.internalPrefix}registry_node*)$l3;',
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };
}

class Cpp extends Base<
  CppConfig,
  CppLibraryConfig,
  CppTypeMarshal,
  CppLibrary,
  CppMarshalSet
> {
  public function new(config:CppConfig) {
    super("cpp-static", config);
    if (!config.staticLink) throw "todo";
  }

  public function finalise():BuildProgram {
    var ops:Array<BuildOp> = [];
    var tdefs = [];
    for (lib in libraries) {
      var ext = lib.config.abi.extension();
      var exth = lib.config.abi.extensionHeader();
      var absLibPath = sys.FileSystem.absolutePath('${config.buildPath}/${lib.config.name}');
      var headerPath = '$absLibPath/lib.cpp_static.$exth';
      var codePath = '$absLibPath/lib.cpp_static.$ext';
      lib.tdef.meta.push({
        pos: Context.currentPos(),
        params: [macro $v{"#include \"" + headerPath + "\""}],
        name: ":headerCode",
      });
      lib.tdef.meta.push({
        pos: Context.currentPos(),
        params: [macro $v{"#include \"" + codePath + "\""}],
        name: ":cppFileCode",
      });
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.cpp_static.$exth'),
        WriteContent(lib.lbHeader.done())
      ));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.cpp_static.$ext'),
        WriteContent(lib.lb.done())
      ));
      for (tdef in lib.tdefs) {
        tdefs.push(tdef);
      }
      for (nativeType in lib.nativeTypes) {
        nativeType.tdef.meta.push({
          pos: lib.config.pos,
          params: [macro $v{"#include \"" + headerPath + "\""}],
          name: ":headerCode",
        });
      }
    }
    return new BuildProgram(ops, tdefs);
  }
}

@:structInit
class CppConfig extends BaseConfig {
  public var staticLink:Bool = true;
}

@:allow(ammer.core.plat.Cpp)
class CppLibrary extends BaseLibrary<
  CppLibrary,
  CppLibraryConfig,
  CppTypeMarshal,
  CppMarshalSet
> {
  var lbHeader = new LineBuf();
  var nativeTypes:Map<String, {
    tdef:TypeDefinition,
    fields:Map<String, Bool>,
  }> = new Map();

  public function new(config:CppLibraryConfig) {
    super(config, new CppMarshalSet(this));
    boilerplate(
      "void*",
      "hx::Object*",
      "",
      // TODO: GC moving curr->key would break things (different hash bin)
      "hx::GCAddRoot(&curr->key);",
      "hx::GCRemoveRoot(&curr->key);"
    );
  }

  override public function addInclude(include:SourceInclude):Void {
    super.addInclude(include);
    lbHeader.ail(include.toCode());
  }

  override public function addHeaderCode(code:String):Void {
    lbHeader.ail(code);
  }

  public function addFunction(
    ret:CppTypeMarshal,
    args:Array<CppTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
    lb
      .ai('${ret.l1Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l1Type} _l1_arg_$idx', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('_l1_arg_$idx', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != CppMarshalSet.MARSHAL_VOID)
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
    lbHeader
      .ai('${ret.l1Type} ${name}(')
      .map(args, arg -> arg.l1Type, ", ")
      .a(args.length == 0 ? "void" : "")
      .al(");");
    tdef.fields.push({
      pos: pos,
      name: name,
      meta: [{
        pos: pos,
        params: [macro $v{name}],
        name: ":native",
      }],
      kind: FFun({
        ret: ret.haxeType,
        expr: macro throw 0,
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
    clType:MarshalClosure<CppTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
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
        .ifi(clType.ret != CppMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l1Type} _l1_output;')
          .ai('_l1_output = (${clType.ret.l1Type})(_l1_fn(')
        .ife()
          .ai('(${clType.ret.l1Type})(_l1_fn(')
        .ifd()
        .mapi(args, (idx, arg) -> '_l1_arg_${idx}', ", ")
        .al("));")
        .ifi(clType.ret != CppMarshalSet.MARSHAL_VOID)
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ifd()
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
        .ifi(ret != CppMarshalSet.MARSHAL_VOID)
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

typedef CppLibraryConfig = LibraryConfig;
typedef CppTypeMarshal = BaseTypeMarshal;

#end
