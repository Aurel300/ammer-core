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

  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

  static final MARSHAL_REF = (l2:String) -> 'Py_XINCREF($l2);';
  static final MARSHAL_UNREF = (l2:String) -> 'Py_XDECREF($l2);';

  static final MARSHAL_VOID:PythonTypeMarshal = {
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
    //pyTupleName: "",
  };

  static final MARSHAL_BOOL:PythonTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "PyObject*",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: (l1, l2) -> '$l2 = ($l1 == Py_True);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyBool_FromLong($l2);',
    //pyTupleName: "O",
  };

  static final MARSHAL_UINT8:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "uint32_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsUnsignedLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLong($l2);',
    //pyTupleName: "B",
  };
  static final MARSHAL_INT8:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "int32_t",
    l3Type: "int8_t",
    mangled: "i8",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
    //pyTupleName: "b",
  };
  static final MARSHAL_UINT16:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "uint32_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
    //pyTupleName: "H",
  };
  static final MARSHAL_INT16:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "int32_t",
    l3Type: "int16_t",
    mangled: "i16",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
    //pyTupleName: "h",
  };
  static final MARSHAL_UINT32:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
    //pyTupleName: "I",
  };
  static final MARSHAL_INT32:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: (l1, l2) -> '$l2 = PyLong_AsLong($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromLong($l2);',
    //pyTupleName: "i",
  };
  // TODO: why are the SetAttrString calls needed after a call to new?
  static final MARSHAL_UINT64:PythonTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "PyObject*",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: (l1, l2) -> 'do {
  uint32_t _python_high = PyLong_AsLong(PyObject_GetAttrString($l1, "high"));
  uint32_t _python_low = PyLong_AsLong(PyObject_GetAttrString($l1, "low"));
  $l2 = (((uint64_t)_python_high) << 32) | (uint32_t)_python_low;
} while (0);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'do {
  PyObject *_python_tmp = Py_BuildValue("(kk)", 0, 0);
  $l1 = _ammer_haxe_int64_type->tp_new(_ammer_haxe_int64_type, _python_tmp, Py_None);
  PyObject_SetAttrString($l1, "high", PyLong_FromUnsignedLong(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
  PyObject_SetAttrString($l1, "low", PyLong_FromUnsignedLong($l2 & 0xFFFFFFFF));
} while (0);',
    //pyTupleName: "O",
  };
  static final MARSHAL_INT64:PythonTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "PyObject*",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
    l1l2: (l1, l2) -> 'do {
  uint32_t _python_high = PyLong_AsLong(PyObject_GetAttrString($l1, "high"));
  uint32_t _python_low = PyLong_AsLong(PyObject_GetAttrString($l1, "low"));
  $l2 = (((int64_t)_python_high) << 32) | (uint32_t)_python_low;
} while (0);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'do {
  PyObject *_python_tmp = Py_BuildValue("(ll)", 0, 0);
  $l1 = _ammer_haxe_int64_type->tp_new(_ammer_haxe_int64_type, _python_tmp, Py_None);
  PyObject_SetAttrString($l1, "high", PyLong_FromLong((int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF)));
  PyObject_SetAttrString($l1, "low", PyLong_FromLong((int32_t)($l2 & 0xFFFFFFFF)));
} while (0);',
    //pyTupleName: "O",
  };

  //static final MARSHAL_FLOAT32:PythonTypeMarshal = {};
  static final MARSHAL_FLOAT64:PythonTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "PyObject*",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: (l1, l2) -> '$l2 = PyFloat_AsDouble($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyFloat_FromDouble($l2);',
    //pyTupleName: "d",
  };

  static final MARSHAL_STRING:PythonTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "PyObject*",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: (l1, l2) -> '$l2 = PyUnicode_AsUTF8($l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyUnicode_FromString($l2);',
    //pyTupleName: "s",
  };

  static final MARSHAL_BYTES:PythonTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> '$l2 = (uint8_t*)(PyLong_AsUnsignedLongLong($l1));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
    //pyTupleName: "?",
  };

  public function new(library:PythonLibrary) {
    super(library);
  }

  public function void():PythonTypeMarshal return MARSHAL_VOID;

  public function bool():PythonTypeMarshal return MARSHAL_BOOL;

  public function uint8():PythonTypeMarshal return MARSHAL_UINT8;
  public function int8():PythonTypeMarshal return MARSHAL_INT8;
  public function uint16():PythonTypeMarshal return MARSHAL_UINT16;
  public function int16():PythonTypeMarshal return MARSHAL_INT16;
  public function uint32():PythonTypeMarshal return MARSHAL_UINT32;
  public function int32():PythonTypeMarshal return MARSHAL_INT32;
  public function uint64():PythonTypeMarshal return MARSHAL_UINT64;
  public function int64():PythonTypeMarshal return MARSHAL_INT64;

  public function float32():PythonTypeMarshal return throw "!";
  public function float64():PythonTypeMarshal return MARSHAL_FLOAT64;

  public function string():PythonTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():PythonTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:PythonTypeMarshal,
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  } {
    var tdefExternExpr = library.tdefExternExpr;
    var tdefBytesRef = library.typeDefCreate();
    tdefBytesRef.name += "_BytesRef";
    tdefBytesRef.fields = (macro class BytesRef {
      public var bytes(default, null):haxe.io.Bytes;
      public var ptr(default, null):Int;
      private var view:Int;
      public function unref():Void {
        if (bytes != null) {
          (@:privateAccess $tdefExternExpr._ammer_python_frombytesunref)(view);
          bytes = null;
          ptr = 0;
          view = 0;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:Int, view:Int) {
        this.bytes = bytes;
        this.ptr = ptr;
        this.view = view;
      }
    }).fields;
    var pathBytesRef:TypePath = {
      name: tdefBytesRef.name,
      pack: tdefBytesRef.pack,
    };
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

  function opaquePtrInternal(name:String):PythonTypeMarshal return {
    haxeType: (macro : Int),
    l1Type: "PyObject*",
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: (l1, l2) -> '$l2 = ($name*)(PyLong_AsUnsignedLongLong($l1));',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> '$l1 = PyLong_FromUnsignedLongLong((uint64_t)$l2);',
    //pyTupleName: "K",
  };

  function haxePtrInternal(haxeType:ComplexType):PythonTypeMarshal return {
    haxeType: haxeType,
    l1Type: "PyObject*",
    l2Type: "PyObject*",
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_UNREF,
    l2l1: MARSHAL_CONVERT_DIRECT,
    //pyTupleName: "O",
  };

  function closureInternal(
    ret:PythonTypeMarshal,
    args:Array<PythonTypeMarshal>
  ):PythonTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "PyObject*",
    l2Type: "PyObject*",
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_UNREF,
    l2l1: MARSHAL_CONVERT_DIRECT,
    //pyTupleName: "O",
  };
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
          .a(lib.lbInit.done())
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
      kind: FFun({
        ret: (macro : haxe.io.BytesData),
        expr: null,
        args: [{
          type: (macro : Int),
          name: "arg1",
        }, {
          type: (macro : Int),
          name: "arg2",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytescopy",
      kind: FFun({
        ret: (macro : Int),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytesref",
      kind: FFun({
        ret: (macro : python.Tuple.Tuple2<Int, Int>),
        expr: null,
        args: [{
          type: (macro : haxe.io.BytesData),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_python_frombytesunref",
      kind: FFun({
        ret: (macro : Void),
        expr: null,
        args: [{
          type: (macro : Int),
          name: "arg1",
        }],
      }),
      access: [APrivate, AStatic],
    });
    tdefExtern.fields.push({
      pos: config.pos,
      name: "_ammer_init",
      kind: FFun({
        ret: (macro : Void),
        expr: null,
        args: [{
          type: (macro : haxe.Int64),
          name: "ex_int64",
        }],
      }),
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
  memcpy(view.buf, data, size);
  PyBuffer_Release(&view);
  return res;
}
static PyObject* _ammer_python_frombytescopy(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer view;
  PyObject_GetBuffer(PyTuple_GetItem(_python_args, 0), &view, PyBUF_C_CONTIGUOUS);
  uint8_t* data_res = (uint8_t*)malloc(view.len); // TODO: malloc
  memcpy(data_res, view.buf, view.len);
  PyBuffer_Release(&view);
  return PyLong_FromUnsignedLongLong((uint64_t)data_res);
}
static PyObject* _ammer_python_frombytesref(PyObject *_python_self, PyObject *_python_args) {
  Py_buffer* view = (Py_buffer*)malloc(sizeof(Py_buffer));
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
  free(view); // TODO: free
  Py_RETURN_NONE;
}
');
  }

  public function addFunction(
    ret:PythonTypeMarshal,
    args:Array<PythonTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
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
        .ifi(ret != PythonMarshalSet.MARSHAL_VOID)
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
      kind: FFun({
        ret: ret.haxeType,
        expr: null,
        args: [ for (i => arg in args) {
          type: arg.haxeType,
          name: 'arg$i',
        } ],
      }),
      access: [APrivate, AStatic],
    });
    var callArgs = [ for (i => arg in args) macro $i{'arg$i'} ];
    tdef.fields.push({
      pos: pos,
      name: name,
      kind: FFun({
        ret: ret.haxeType,
        expr: macro return (@:privateAccess $tdefExternExpr.$name)($a{callArgs}),
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
        .ifi(clType.ret != PythonMarshalSet.MARSHAL_VOID)
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
        .ifi(ret != PythonMarshalSet.MARSHAL_VOID)
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
