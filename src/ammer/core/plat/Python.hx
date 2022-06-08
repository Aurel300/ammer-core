package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

@:allow(ammer.core.plat.Python)
class PythonMarshalSet extends BaseMarshalSet<
  PythonMarshalSet,
  PythonLibraryConfig,
  PythonLibrary,
  PythonTypeMarshal
> {
  // TODO: deal with references...
  // Reference counting
  // https://docs.python.org/3/extending/extending.html#reference-counts
  static final MARSHAL_REF = (l2:String) -> 'Py_XINCREF($l2);';
  static final MARSHAL_UNREF = (l2:String) -> 'Py_XDECREF($l2);';

  static function baseExtend(
    base:BaseTypeMarshal,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):PythonTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "PyObject*", a Python object pointer
      l1Type:   "PyObject*",
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
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshalSet.baseVoid());
  public function void():PythonTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshalSet.baseBool(), {
    l1l2: (l1, l2) -> '$l2 = ($l1 == Py_True);',
    l2l1: (l2, l1) -> '$l1 = PyBool_FromLong($l2);',
  });
  public function bool():PythonTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshalSet.baseUint8(), {
    l2Type: "uint32_t",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsUnsignedLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLong($l2);',
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshalSet.baseInt8(), {
    l2Type: "int32_t",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshalSet.baseUint16(), {
    l2Type: "uint32_t",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshalSet.baseInt16(), {
    l2Type: "int32_t",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshalSet.baseUint32(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshalSet.baseInt32(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  public function uint8():PythonTypeMarshal return MARSHAL_UINT8;
  public function int8():PythonTypeMarshal return MARSHAL_INT8;
  public function uint16():PythonTypeMarshal return MARSHAL_UINT16;
  public function int16():PythonTypeMarshal return MARSHAL_INT16;
  public function uint32():PythonTypeMarshal return MARSHAL_UINT32;
  public function int32():PythonTypeMarshal return MARSHAL_INT32;

  // TODO: why are the SetAttrString calls needed after a call to new?
  static final MARSHAL_UINT64 = baseExtend(BaseMarshalSet.baseUint64(), {
    l1l2: (l1, l2) -> 'do {
  uint32_t _python_high = PyLong_AsLong(PyObject_GetAttrString($l1, "high"));
  uint32_t _python_low = PyLong_AsLong(PyObject_GetAttrString($l1, "low"));
  $l2 = (((uint64_t)_python_high) << 32) | (uint32_t)_python_low;
} while (0);',
    l2l1: (l2, l1) -> 'do {
  PyObject *_python_tmp = Py_BuildValue("(kk)", 0, 0);
  $l1 = _ammer_haxe_int64_type->tp_new(_ammer_haxe_int64_type, _python_tmp, Py_None);
  PyObject_SetAttrString($l1, "high", PyLong_FromUnsignedLong(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
  PyObject_SetAttrString($l1, "low", PyLong_FromUnsignedLong($l2 & 0xFFFFFFFF));
} while (0);',
  });
  static final MARSHAL_INT64  = baseExtend(BaseMarshalSet.baseInt64(), {
    l1l2: (l1, l2) -> 'do {
  uint32_t _python_high = PyLong_AsLong(PyObject_GetAttrString($l1, "high"));
  uint32_t _python_low = PyLong_AsLong(PyObject_GetAttrString($l1, "low"));
  $l2 = (((int64_t)_python_high) << 32) | (uint32_t)_python_low;
} while (0);',
    l2l1: (l2, l1) -> 'do {
  PyObject *_python_tmp = Py_BuildValue("(ll)", 0, 0);
  $l1 = _ammer_haxe_int64_type->tp_new(_ammer_haxe_int64_type, _python_tmp, Py_None);
  PyObject_SetAttrString($l1, "high", PyLong_FromLong((int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF)));
  PyObject_SetAttrString($l1, "low", PyLong_FromLong((int32_t)($l2 & 0xFFFFFFFF)));
} while (0);',
  });
  public function uint64():PythonTypeMarshal return MARSHAL_UINT64;
  public function int64():PythonTypeMarshal return MARSHAL_INT64;

  // static final MARSHAL_FLOAT32 = baseExtend(BaseMarshalSet.baseFloat32(), {
  //   l1l2: (l1, l2) -> '$l2 = PyFloat_AsDouble($l1);',
  //   l2l1: (l2, l1) -> '$l1 = PyFloat_FromDouble($l2);',
  // });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshalSet.baseFloat64(), {
    l1l2: (l1, l2) -> '$l2 = PyFloat_AsDouble($l1);',
    l2l1: (l2, l1) -> '$l1 = PyFloat_FromDouble($l2);',
  });
  public function float32():PythonTypeMarshal return throw "!";
  public function float64():PythonTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshalSet.baseString(), {
    l1l2: (l1, l2) -> '$l2 = PyUnicode_AsUTF8($l1);',
    l2l1: (l2, l1) -> '$l1 = PyUnicode_FromString($l2);',
  });
  public function string():PythonTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshalSet.baseBytesInternal(), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });
  function bytesInternalType():PythonTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  } {
    var tdefExternExpr = library.tdefExternExpr;
    var pathBytesRef = baseBytesRef(
      (macro : Int), macro 0,
      (macro : Int), macro 0,
      macro (@:privateAccess $tdefExternExpr._ammer_python_frombytesunref)(handle)
    );
    return {
      toBytesCopy: (self, size) -> macro {
        var _self:Int = $self;
        var _size:Int = $size;
        var _res:haxe.io.BytesData = (@:privateAccess $tdefExternExpr._ammer_python_tobytescopy)(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromBytesCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $tdefExternExpr._ammer_python_frombytescopy)(_bytes.getData());
      },

      toBytesRef: null,
      fromBytesRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret:python.Tuple.Tuple2<Int, Int> = (@:privateAccess $tdefExternExpr._ammer_python_frombytesref)(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ret._2, _ret._1));
      },
    };
  }

  function opaquePtrInternal(name:String):PythonTypeMarshal return baseExtend(BaseMarshalSet.baseOpaquePtrInternal(name), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = ($name*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });

  function arrayPtrInternalType(element:PythonTypeMarshal):PythonTypeMarshal return baseExtend(BaseMarshalSet.baseArrayPtrInternal(element), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = (${element.l3Type}*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });

  function haxePtrInternal(haxeType:ComplexType):PythonTypeMarshal return baseExtend(BaseMarshalSet.baseHaxePtrInternal(haxeType), {
    haxeType: haxeType,
    l2Type: "PyObject*",
    l2ref: MARSHAL_REF,
    l2unref: MARSHAL_UNREF,
  });

  public function new(library:PythonLibrary) {
    super(library);
  }
}

class Python extends Base<
  PythonConfig,
  PythonLibraryConfig,
  PythonTypeMarshal,
  PythonLibrary,
  PythonMarshalSet
> {
  public function new(config:PythonConfig) {
    super("python", config);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.pythonIncludePaths,
      libraryPaths: config.pythonLibraryPaths,
      defines: ["NDEBUG", "MAJOR_VERSION=1", "MINOR_VERSION=0"],
      // TODO: versioning ...
      linkNames: ["python3.6"],
      // .so is intentional, even on OS X
      // TODO: check windows
      outputPath: lib -> '${config.outputPath}/${lib.config.name}.so',
      libCode: lib -> lib.lb
        .ail('static PyObject *_ammer_init(PyObject *_python_self, PyObject *_python_args) {')
        .i()
          .ail("PyObject *ex_int64;")
          // TODO: get rid of parsetuple
          .ail("if (!PyArg_ParseTuple(_python_args, \"O\", &ex_int64)) return NULL;")
          .ail("_ammer_haxe_int64_type = Py_TYPE(ex_int64);")
          .ail("Py_RETURN_NONE;")
        .d()
        .al("}")
        .ail('PyMODINIT_FUNC PyInit_${lib.config.name}(void) {')
        .i()
          .ail("static PyMethodDef _init_wrap[] = {")
          .addBuf(lib.lbInit)
          .ail("{\"_ammer_python_tobytescopy\", _ammer_python_tobytescopy, METH_VARARGS, \"\"},")
          .ail("{\"_ammer_python_frombytescopy\", _ammer_python_frombytescopy, METH_VARARGS, \"\"},")
          .ail("{\"_ammer_python_frombytesref\", _ammer_python_frombytesref, METH_VARARGS, \"\"},")
          .ail("{\"_ammer_python_frombytesunref\", _ammer_python_frombytesunref, METH_VARARGS, \"\"},")
          .ail("{\"_ammer_init\", _ammer_init, METH_VARARGS, \"\"},")
          .ail("{NULL, NULL, 0, NULL}")
          .ail("};")
          .ail("static struct PyModuleDef _init_module = {")
          .i()
            .ail('PyModuleDef_HEAD_INIT,')
            .ail('"${lib.config.name}",')
            .ail('NULL,')
            .ail('-1,')
            .ail('_init_wrap')
          .d()
          .ail("};")
          .ail("return PyModule_Create2(&_init_module, PYTHON_API_VERSION);")
        .d()
        .ail("}")
        .done(),
    });
  }
}

@:structInit
class PythonConfig extends BaseConfig {
  public var pythonIncludePaths:Array<String> = null;
  public var pythonLibraryPaths:Array<String> = null;
}

@:allow(ammer.core.plat.Python)
class PythonLibrary extends BaseLibrary<
  PythonLibrary,
  PythonLibraryConfig,
  PythonTypeMarshal,
  PythonMarshalSet
> {
  var lbInit = new LineBuf();
  var tdefExtern:TypeDefinition;
  var tdefExternExpr:Expr;

  public function new(config:PythonLibraryConfig) {
    super(config, new PythonMarshalSet(this));
    tdefExtern = typeDefCreate();
    tdefExtern.name += "_Native";
    tdefExtern.isExtern = true;
    tdefExtern.meta.push({
      pos: config.pos,
      params: [macro $v{config.name}],
      name: ":pythonImport",
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_tobytescopy",
      kind: TypeUtils.ffunCt((macro : (Int, Int) -> haxe.io.BytesData)),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytescopy",
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData) -> Int)),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytesref",
      kind: TypeUtils.ffunCt((macro : (haxe.io.BytesData) -> python.Tuple.Tuple2<Int, Int>)),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytesunref",
      kind: TypeUtils.ffunCt((macro : (Int) -> Void)),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_init",
      kind: TypeUtils.ffunCt((macro : (haxe.Int64) -> Void)),
      access: [APrivate, AStatic],
    });
    tdefExternExpr = macro $p{config.typeDefPack.concat([config.typeDefName + "_Native"])};
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          @:privateAccess $tdefExternExpr._ammer_init(haxe.Int64.make(0, 0));
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    lb.ail("#define PY_SSIZE_T_CLEAN");
    lb.ail("#include <Python.h>");
    lb.ail("static PyTypeObject *_ammer_haxe_int64_type;");
    lb.ail('
static PyObject* _ammer_python_tobytescopy(PyObject *_python_self, PyObject *_python_args) {
  uint8_t* data = (uint8_t*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  size_t size = PyLong_AsLong(PyTuple_GetItem(_python_args, 1));
  PyObject* res = PyByteArray_FromStringAndSize(NULL, size);
  Py_buffer view;
  PyObject_GetBuffer(res, &view, PyBUF_WRITABLE | PyBUF_C_CONTIGUOUS);
  ${config.memcpyFunction}(view.buf, data, size);
  PyBuffer_Release(&view);
  return res;
}
static PyObject* _ammer_python_frombytescopy(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer view;
  PyObject_GetBuffer(PyTuple_GetItem(_python_args, 0), &view, PyBUF_C_CONTIGUOUS);
  uint8_t* data_res = (uint8_t*)${config.mallocFunction}(view.len);
  ${config.memcpyFunction}(data_res, view.buf, view.len);
  PyBuffer_Release(&view);
  return PyLong_FromUnsignedLongLong((uint64_t)data_res);
}
static PyObject* _ammer_python_frombytesref(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer* view = (Py_buffer*)${config.mallocFunction}(sizeof(Py_buffer));
  PyObject_GetBuffer(PyTuple_GetItem(_python_args, 0), view, PyBUF_C_CONTIGUOUS); // TODO: writable flag?
  uint8_t* data = view->buf;
  return PyTuple_Pack(2,
    PyLong_FromUnsignedLongLong((uint64_t)view),
    PyLong_FromUnsignedLongLong((uint64_t)data)
  );
}
static PyObject* _ammer_python_frombytesunref(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer* view = (Py_buffer*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  PyBuffer_Release(view);
  ${config.freeFunction}(view);
  Py_RETURN_NONE;
}
');
  }

  public function addNamedFunction(
    name:String,
    ret:PythonTypeMarshal,
    args:Array<PythonTypeMarshal>,
    code:String,
    pos:Position
  ):Expr {
    lb
      .ail('static PyObject *${name}(PyObject *_python_self, PyObject *_python_args) {')
      .i()
        .ifi(args.length > 0)
          .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
          .lmapi(args, (idx, arg) -> arg.l1l2('PyTuple_GetItem(_python_args, $idx)', '_l2_arg_$idx'))
          .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
          .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
          .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifd()
        .ifi(ret.mangled != "v")
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('${ret.l2Type} _l2_return;')
          .ail(ret.l3l2(config.returnIdent, "_l2_return"))
          .ail('${ret.l1Type} _l1_return;')
          .ail(ret.l2ref("_l2_return")) // TODO: is this correct?
          .ail(ret.l2l1("_l2_return", "_l1_return"))
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail('return _l1_return;')
        .ife()
          .ail(code)
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail("Py_RETURN_NONE;")
        .ifd()
      .d()
      .al("}");
    lbInit.ail('{"${name}", ${name}, METH_VARARGS, ""},');
    tdefExtern.fields.push({
      pos: pos,
      name: name,
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType),
      access: [APrivate, AStatic],
    });
    var callArgs = [ for (i => arg in args) macro $i{'arg$i'} ];
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: TypeUtils.ffun(
        args.map(arg -> arg.haxeType),
        ret.haxeType,
        macro return (@:privateAccess $tdefExternExpr.$name)($a{callArgs})
      ),
      access: [APublic, AStatic, AInline],
    });
    return fieldExpr(name);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<PythonTypeMarshal>,
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
        .ai('PyObject* _python_args = PyTuple_Pack(${args.length}')
        .mapi(args, (idx, arg) -> ', _l1_arg_$idx')
        .al(");")
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l1Type} _l1_output;')
          .ail("_l1_output = PyObject_CallObject(_l1_fn, _python_args);")
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("_l1_output", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
        .ife()
          .ail("PyObject_CallObject(_l1_fn, _python_args);")
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:PythonTypeMarshal,
    args:Array<PythonTypeMarshal>,
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

typedef PythonLibraryConfig = LibraryConfig;
typedef PythonTypeMarshal = BaseTypeMarshal;

#end
