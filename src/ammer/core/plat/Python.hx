package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

@:structInit
class PythonConfig extends BaseConfig {
  public var pythonVersionMinor = 8; // 3.8
  public var pythonIncludePaths:Array<String> = null;
  public var pythonLibraryPaths:Array<String> = null;
}

typedef PythonLibraryConfig = LibraryConfig;

typedef PythonTypeMarshal = BaseTypeMarshal;

class Python extends Base<
  Python,
  PythonConfig,
  PythonLibraryConfig,
  PythonTypeMarshal,
  PythonLibrary,
  PythonMarshal
> {
  public function new(config:PythonConfig) {
    super("python", config);
  }

  public function createLibrary(libConfig:PythonLibraryConfig):PythonLibrary {
    return new PythonLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.pythonIncludePaths,
      libraryPaths: config.pythonLibraryPaths,
      defines: ["NDEBUG", "MAJOR_VERSION=1", "MINOR_VERSION=0"],
      linkNames: ['python3${BuildProgram.useMSVC ? "" : "."}${config.pythonVersionMinor}'],
      // .so is intentional on macOS
      outputPath: lib -> '${config.outputPath}/${lib.config.name}.${BuildProgram.useMSVC ? "pyd" : "so"}',
    });
  }
}

@:allow(ammer.core.plat)
class PythonLibrary extends BaseLibrary<
  PythonLibrary,
  Python,
  PythonConfig,
  PythonLibraryConfig,
  PythonTypeMarshal,
  PythonMarshal
> {
  var lbInit = new LineBuf();
  var tdefExtern:TypeDefinition;
  var tdefExternExpr:Expr;

  function pushNative(name:String, signature:ComplexType, pos:Position):Void {
    tdefExtern.fields.push({
      pos: pos,
      name: name,
      kind: TypeUtils.ffunCt(signature),
      access: [APrivate, AStatic],
    });
  }

  public function new(platform:Python, config:PythonLibraryConfig) {
    super(platform, config, new PythonMarshal(this));
    tdefExtern = typeDefCreate();
    tdefExtern.name += "_Native";
    tdefExtern.isExtern = true;
    tdefExtern.meta.push({
      pos: config.pos,
      params: [macro $v{config.name}],
      name: ":pythonImport",
    });

    pushNative("_ammer_python_tohaxecopy", (macro : (Int, Int) -> haxe.io.BytesData), config.pos);
    pushNative("_ammer_python_fromhaxecopy", (macro : (haxe.io.BytesData) -> Int), config.pos);
    pushNative("_ammer_python_fromhaxeref", (macro : (haxe.io.BytesData) -> python.Tuple.Tuple2<Int, Int>), config.pos);
    pushNative("_ammer_python_frombytesunref", (macro : (Int) -> Void), config.pos);

    pushNative("_ammer_ref_create",   (macro : (Dynamic) -> Int), config.pos);
    pushNative("_ammer_ref_delete",   (macro : (Int) -> Void), config.pos);
    pushNative("_ammer_ref_getcount", (macro : (Int) -> Int), config.pos);
    pushNative("_ammer_ref_setcount", (macro : (Int, Int) -> Void), config.pos);
    pushNative("_ammer_ref_getvalue", (macro : (Int) -> Dynamic), config.pos);

    pushNative("_ammer_init", (macro : (haxe.Int64) -> Void), config.pos);

    tdefExternExpr = macro $p{config.typeDefPack.concat([config.typeDefName + "_Native"])};
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : Int),
        macro {
          @:privateAccess $tdefExternExpr._ammer_init(haxe.Int64.make(0xF0000000, 0xF0000000));
          0;
        }
      ),
      access: [APrivate, AStatic],
    });
    lb.ail("#define PY_SSIZE_T_CLEAN");
    lb.ail("#include <Python.h>");
    lb.ail("static PyTypeObject *_ammer_haxe_int64_type;");
    lb.ail('
static PyObject* _ammer_python_tohaxecopy(PyObject *_python_self, PyObject *_python_args) {
  uint8_t* data = (uint8_t*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  size_t size = PyLong_AsLong(PyTuple_GetItem(_python_args, 1));
  PyObject* res = PyByteArray_FromStringAndSize(NULL, size);
  Py_buffer view;
  PyObject_GetBuffer(res, &view, PyBUF_WRITABLE | PyBUF_C_CONTIGUOUS);
  ${config.memcpyFunction}(view.buf, data, size);
  PyBuffer_Release(&view);
  return res;
}
static PyObject* _ammer_python_fromhaxecopy(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer view;
  PyObject_GetBuffer(PyTuple_GetItem(_python_args, 0), &view, PyBUF_C_CONTIGUOUS);
  uint8_t* data_res = (uint8_t*)${config.mallocFunction}(view.len);
  ${config.memcpyFunction}(data_res, view.buf, view.len);
  PyBuffer_Release(&view);
  return PyLong_FromUnsignedLongLong((uint64_t)data_res);
}
static PyObject* _ammer_python_fromhaxeref(PyObject *_python_self, PyObject *_python_args) {
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

typedef struct { PyObject* value; int32_t refcount; } _ammer_haxe_ref;
static PyObject* _ammer_ref_create(PyObject *_python_self, PyObject *_python_args) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = PyTuple_GetItem(_python_args, 0);
  ref->refcount = 0;
  Py_XINCREF(ref->value);
  return PyLong_FromUnsignedLongLong((uint64_t)ref);
}
static PyObject* _ammer_ref_delete(PyObject *_python_self, PyObject *_python_args) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  Py_XDECREF(ref->value);
  ref->value = NULL;
  ${config.freeFunction}(ref);
  Py_RETURN_NONE;
}
static PyObject* _ammer_ref_getcount(PyObject *_python_self, PyObject *_python_args) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  return PyLong_FromLong(ref->refcount);
}
static PyObject* _ammer_ref_setcount(PyObject *_python_self, PyObject *_python_args) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  int32_t rc = PyLong_AsLong(PyTuple_GetItem(_python_args, 1));
  ref->refcount = rc;
  Py_RETURN_NONE;
}
static PyObject* _ammer_ref_getvalue(PyObject *_python_self, PyObject *_python_args) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)(PyLong_AsUnsignedLongLong(PyTuple_GetItem(_python_args, 0)));
  if (ref->value == NULL) {
    Py_RETURN_NONE;
  } else {
    Py_XINCREF(ref->value);
    return ref->value;
  }
}
');
  }

  override function finalise(platConfig:PythonConfig):Void {
    lb
      .ail('static PyObject *_ammer_init(PyObject *_python_self, PyObject *_python_args) {
  PyObject *ex_int64;
  // TODO: get rid of parsetuple
  if (!PyArg_ParseTuple(_python_args, \"O\", &ex_int64)) return NULL;
  _ammer_haxe_int64_type = Py_TYPE(ex_int64);
  Py_RETURN_NONE;
}
PyMODINIT_FUNC PyInit_${config.name}(void) {
  static PyMethodDef _init_wrap[] = {
').addBuf(lbInit).ail('
    {"_ammer_python_tohaxecopy", _ammer_python_tohaxecopy, METH_VARARGS, ""},
    {"_ammer_python_fromhaxecopy", _ammer_python_fromhaxecopy, METH_VARARGS, ""},
    {"_ammer_python_fromhaxeref", _ammer_python_fromhaxeref, METH_VARARGS, ""},
    {"_ammer_python_frombytesunref", _ammer_python_frombytesunref, METH_VARARGS, ""},
    {"_ammer_ref_create", _ammer_ref_create, METH_VARARGS, ""},
    {"_ammer_ref_delete", _ammer_ref_delete, METH_VARARGS, ""},
    {"_ammer_ref_getcount", _ammer_ref_getcount, METH_VARARGS, ""},
    {"_ammer_ref_setcount", _ammer_ref_setcount, METH_VARARGS, ""},
    {"_ammer_ref_getvalue", _ammer_ref_getvalue, METH_VARARGS, ""},
    {"_ammer_init", _ammer_init, METH_VARARGS, ""},
    {NULL, NULL, 0, NULL}
  };
  static struct PyModuleDef _init_module = {
    PyModuleDef_HEAD_INIT,
    "${config.name}",
    NULL,
    -1,
    _init_wrap
  };
  return PyModule_Create2(&_init_module, PYTHON_API_VERSION);
}');
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:PythonTypeMarshal,
    args:Array<PythonTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ail('static PyObject *${name}(PyObject *_python_self, PyObject *_python_args) {')
      .i();
    baseAddNamedFunction(
      args,
      args.mapi((idx, arg) -> 'PyTuple_GetItem(_python_args, $idx)'),
      ret,
      "_l1_return",
      code,
      lb,
      options
    );
    lb
        .ifi(ret.mangled != "v")
          // this incref is separate from the usual reference bookkeeping,
          // and is here because functions are expected to return an owned
          // value already in Python (the caller will decref it as needed)
          .ail("Py_XINCREF(_l1_return);")
          .ail('return _l1_return;')
        .ife()
          .ail("Py_RETURN_NONE;")
        .ifd()
      .d()
      .ail("}");
    lbInit.ail('{"${name}", ${name}, METH_VARARGS, ""},');
    tdefExtern.fields.push({
      pos: options.pos,
      name: name,
      kind: TypeUtils.ffun(args.map(arg -> arg.haxeType), ret.haxeType),
      access: [APrivate, AStatic],
    });
    var callArgs = [ for (i => arg in args) macro $i{'arg$i'} ];
    tdef.fields.push({
      pos: options.pos,
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
        .ail("PyObject* _l1_fn_ref;")
        .ail(clType.type.l2l1("_l2_fn", "_l1_fn_ref"))
        .ail("PyObject* _l1_fn;")
        .ail("_l1_fn = ((_ammer_haxe_ref*)PyLong_AsUnsignedLongLong(_l1_fn_ref))->value;")
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

@:allow(ammer.core.plat)
class PythonMarshal extends BaseMarshal<
  PythonMarshal,
  Python,
  PythonConfig,
  PythonLibraryConfig,
  PythonLibrary,
  PythonTypeMarshal
> {
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
      l2l3:      over != null && over.l2l3      != null ? over.l2l3      : base.l2l3,
      l3l2:      over != null && over.l3l2      != null ? over.l3l2      : base.l3l2,
      l2l1:      over != null && over.l2l1      != null ? over.l2l1      : base.l2l1,
      arrayBits: over != null && over.arrayBits != null ? over.arrayBits : base.arrayBits,
      arrayType: over != null && over.arrayType != null ? over.arrayType : base.arrayType,
    };
  }

  static final MARSHAL_VOID = baseExtend(BaseMarshal.baseVoid());
  public function void():PythonTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
    l1l2: (l1, l2) -> '$l2 = ($l1 == Py_True);',
    l2l1: (l2, l1) -> '$l1 = PyBool_FromLong($l2);',
  });
  public function bool():PythonTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsUnsignedLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLong($l2);',
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
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
  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    l1l2: (l1, l2) -> 'do {
  uint32_t _python_high = PyLong_AsLong(PyObject_GetAttrString($l1, "high"));
  uint32_t _python_low = PyLong_AsLong(PyObject_GetAttrString($l1, "low"));
  $l2 = (((uint64_t)_python_high) << 32) | (uint32_t)_python_low;
} while (0);',
    l2l1: (l2, l1) -> 'do {
  PyObject *_python_tmp = Py_BuildValue("(ll)", 0, 0);
  $l1 = _ammer_haxe_int64_type->tp_new(_ammer_haxe_int64_type, _python_tmp, Py_None);
  PyObject_SetAttrString($l1, "high", PyLong_FromLong((int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF)));
  PyObject_SetAttrString($l1, "low", PyLong_FromLong((int32_t)($l2 & 0xFFFFFFFF)));
} while (0);',
  });
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(), {
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

  // static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat32(), {
  //   l1l2: (l1, l2) -> '$l2 = PyFloat_AsDouble($l1);',
  //   l2l1: (l2, l1) -> '$l1 = PyFloat_FromDouble($l2);',
  // });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    l1l2: (l1, l2) -> '$l2 = PyFloat_AsDouble($l1);',
    l2l1: (l2, l1) -> '$l1 = PyFloat_FromDouble($l2);',
  });
  public function float32():PythonTypeMarshal return throw "!";
  public function float64():PythonTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    l1l2: (l1, l2) -> '$l2 = PyUnicode_AsUTF8($l1);',
    l2l1: (l2, l1) -> '$l1 = PyUnicode_FromString($l2);',
  });
  public function string():PythonTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });
  function bytesInternalType():PythonTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  } {
    var tdefExternExpr = library.tdefExternExpr;
    var pathBytesRef = baseBytesRef(
      (macro : Int), macro 0,
      (macro : Int), macro 0,
      macro (@:privateAccess $tdefExternExpr._ammer_python_frombytesunref)(handle)
    );
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self:Int = $self;
        var _size:Int = $size;
        var _res:haxe.io.BytesData = (@:privateAccess $tdefExternExpr._ammer_python_tohaxecopy)(_self, _size);
        haxe.io.Bytes.ofData(_res);
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes:haxe.io.Bytes = $bytes;
        (@:privateAccess $tdefExternExpr._ammer_python_fromhaxecopy)(_bytes.getData());
      },

      toHaxeRef: null,
      fromHaxeRef: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret:python.Tuple.Tuple2<Int, Int> = (@:privateAccess $tdefExternExpr._ammer_python_fromhaxeref)(_bytes.getData());
        (@:privateAccess new $pathBytesRef(_bytes, _ret._2, _ret._1));
      },
    };
  }

  function opaqueInternal(name:String):MarshalOpaque<PythonTypeMarshal> return {
    type: baseExtend(BaseMarshal.baseOpaquePtrInternal(name), {
      haxeType: (macro : Int),
      l1l2: (l1, l2) -> '$l2 = ($name*)(PyLong_AsUnsignedLongLong($l1));',
      l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
    }),
    typeDeref: baseExtend(BaseMarshal.baseOpaqueDirectInternal(name), {
      haxeType: (macro : Int),
      l1l2: (l1, l2) -> '$l2 = ($name*)(PyLong_AsUnsignedLongLong($l1));',
      l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
    }),
  };

  function arrayPtrInternalType(element:PythonTypeMarshal):PythonTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = (${element.l2Type}*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<PythonTypeMarshal> {
    var tdefExternExpr = library.tdefExternExpr;
    return baseHaxePtrInternal(
      haxeType,
      (macro : Int),
      macro 0,
      macro (@:privateAccess $tdefExternExpr._ammer_ref_getvalue)(handle),
      macro (@:privateAccess $tdefExternExpr._ammer_ref_getcount)(handle),
      rc -> macro (@:privateAccess $tdefExternExpr._ammer_ref_setcount)(handle, $rc),
      value -> macro (@:privateAccess $tdefExternExpr._ammer_ref_create)($value),
      macro (@:privateAccess $tdefExternExpr._ammer_ref_delete)(handle),
      null,
      handle -> macro $handle == null || $handle == 0
    ).marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):PythonTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: (macro : Int),
    l1l2: (l1, l2) -> '$l2 = (PyObject*)(PyLong_AsUnsignedLongLong($l1));',
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
  });

  public function new(library:PythonLibrary) {
    super(library);
  }
}

#end
