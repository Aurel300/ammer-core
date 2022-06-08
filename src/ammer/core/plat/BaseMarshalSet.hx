package ammer.core.plat;

#if macro

import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

abstract class BaseMarshalSet<
  TSelf:BaseMarshalSet<TSelf, TLibraryConfig, TLibrary, TTypeMarshal>,
  TLibraryConfig:LibraryConfig,
  TLibrary:BaseLibrary<TLibrary, TLibraryConfig, TTypeMarshal, TSelf>,
  TTypeMarshal:BaseTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';
  static final MARSHAL_CONVERT_CAST = (type:String) -> (src:String, dst:String) -> '$dst = ($type)$src;';

  public var library:TLibrary;

  var cacheOpaque:Map<String, TTypeMarshal> = [];
  var cacheStruct:Map<String, MarshalStruct<TTypeMarshal>> = [];
  var cacheArray:Map<String, MarshalArray<TTypeMarshal>> = [];
  var cacheHaxe:Map<String, TTypeMarshal> = [];
  var cacheClosure:Map<String, MarshalClosure<TTypeMarshal>> = [];
  var cacheBytes:MarshalBytes<TTypeMarshal>;

  function new(library:TLibrary) {
    this.library = library;
  }

  static function baseVoid():BaseTypeMarshal return {
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
  abstract public function void():TTypeMarshal;

  static function baseBool():BaseTypeMarshal return {
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
  abstract public function bool():TTypeMarshal;

  // TODO: make base marshals into variables?
  static function baseUint8():BaseTypeMarshal return {
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
    arrayBits: 0,
  };
  static function baseInt8():BaseTypeMarshal return {
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
    arrayBits: 0,
  };
  static function baseUint16():BaseTypeMarshal return {
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
    arrayBits: 1,
  };
  static function baseInt16():BaseTypeMarshal return {
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
    arrayBits: 1,
  };
  static function baseUint32():BaseTypeMarshal return {
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
    arrayBits: 2,
  };
  static function baseInt32():BaseTypeMarshal return {
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
    arrayBits: 2,
  };

  static function baseUint64():BaseTypeMarshal return {
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
    arrayBits: 3,
  };
  static function baseInt64():BaseTypeMarshal return {
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
    arrayBits: 3,
  };
  abstract public function uint8():TTypeMarshal;
  abstract public function int8():TTypeMarshal;
  abstract public function uint16():TTypeMarshal;
  abstract public function int16():TTypeMarshal;
  abstract public function uint32():TTypeMarshal;
  abstract public function int32():TTypeMarshal;
  abstract public function uint64():TTypeMarshal;
  abstract public function int64():TTypeMarshal;

  static function baseFloat32():BaseTypeMarshal return {
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
    arrayBits: 2,
  };
  static function baseFloat64():BaseTypeMarshal return {
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
    arrayBits: 3,
  };
  abstract public function float32():TTypeMarshal;
  abstract public function float64():TTypeMarshal;

  static function baseString():BaseTypeMarshal return {
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
  abstract public function string():TTypeMarshal;

  public function bytes():MarshalBytes<TTypeMarshal> {
    if (cacheBytes != null)
      return cacheBytes;

    var type = bytesInternalType();

    var allocF = library.addFunction(
      type,
      [int32()],
      '_return = (uint8_t*)${library.config.mallocFunction}(_arg0);'
    );
    var alloc = (size) -> macro $allocF($size);
    var blitF = library.addFunction(
      void(),
      [type, int32(), type, int32(), int32()],
      '${library.config.memcpyFunction}(&_arg2[_arg3], &_arg0[_arg1], _arg4);'
    );
    var blit = (source, srcpos, dest, dstpos, size) -> macro $blitF($source, $srcpos, $dest, $dstpos, $size);
    var platform = bytesInternalOps(alloc, blit);

    var libExpr = library.typeDefExpr();
    var get8  = library.addFunction(uint8(),  [type, int32()], '_return = _arg0[_arg1];');
    var get16 = library.addFunction(uint16(), [type, int32()], '${library.config.memcpyFunction}(&_return, &_arg0[_arg1], 2);');
    var get32 = library.addFunction(uint32(), [type, int32()], '${library.config.memcpyFunction}(&_return, &_arg0[_arg1], 4);');
    var set8  = library.addFunction(void(), [type, int32(), uint8() ], '_arg0[_arg1] = _arg2;');
    var set16 = library.addFunction(void(), [type, int32(), uint16()], '${library.config.memcpyFunction}(&_arg0[_arg1], &_arg2, 2);');
    var set32 = library.addFunction(void(), [type, int32(), uint32()], '${library.config.memcpyFunction}(&_arg0[_arg1], &_arg2, 4);');
    var zalloc = library.addFunction(
      type,
      [int32()],
      '_return = (uint8_t*)${library.config.callocFunction}(_arg0, 1);'
    );
    // TODO: free should decref all owned fields
    var free = library.addFunction(
      void(),
      [type],
      '${library.config.freeFunction}(_arg0);'
    );
    var copy = library.addFunction(
      type,
      [type, int32()],
      '_return = (uint8_t*)${library.config.mallocFunction}(_arg1);
${library.config.memcpyFunction}(_return, _arg0, _arg1);'
    );
    return cacheBytes = {
      type: type,

      get8:  (self, index) -> macro $get8 ($self, $index),
      get16: (self, index) -> macro $get16($self, $index),
      get32: (self, index) -> macro $get32($self, $index),

      set8:  (self, index, val) -> macro $set8 ($self, $index, $val),
      set16: (self, index, val) -> macro $set16($self, $index, $val),
      set32: (self, index, val) -> macro $set32($self, $index, $val),

      alloc: alloc,
      zalloc: (size) -> macro $zalloc($size),
      free: (self) -> macro $free($self),
      copy: (self, size) -> macro $copy($self, $size),
      blit: blit,

      toBytesCopy: platform.toBytesCopy,
      fromBytesCopy: platform.fromBytesCopy,
      toBytesRef: platform.toBytesRef,
      fromBytesRef: platform.fromBytesRef,
    };
  }

  static function baseBytesInternal():BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
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
  };
  function baseBytesRef(
    ptrType:ComplexType,
    nullPtr:Expr,
    handleType:ComplexType,
    nullHandle:Expr,
    unref:Expr
  ):TypePath {
    var tdefBytesRef = library.typeDefCreate();
    tdefBytesRef.name += "_BytesRef";
    tdefBytesRef.fields = (macro class BytesRef {
      public var bytes(default, null):haxe.io.Bytes;
      public var ptr(default, null):$ptrType;
      private var handle:$handleType;
      public function unref():Void {
        if (bytes != null) {
          $unref;
          bytes = null;
          ptr = $nullPtr;
          handle = $nullHandle;
        }
      }
      private function new(bytes:haxe.io.Bytes, ptr:$ptrType, handle:$handleType) {
        this.bytes = bytes;
        this.ptr = ptr;
        this.handle = handle;
      }
    }).fields;
    return {
      name: tdefBytesRef.name,
      pack: tdefBytesRef.pack,
    };
  }
  // TODO: this is a bit ugly (first calling platform for type, then for ops)
  abstract function bytesInternalType():TTypeMarshal;
  abstract function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  };

  public function opaquePtr(name:String):TTypeMarshal {
    if (cacheOpaque.exists(name))
      return cacheOpaque[name];
    return cacheOpaque[name] = opaquePtrInternal(name);
  }

  static function baseOpaquePtrInternal(name:String):BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
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
  abstract function opaquePtrInternal(name:String):TTypeMarshal;

  public function structPtr(
    name:String,
    fields:Array<BaseFieldRef<TTypeMarshal>>,
    allocatable:Bool = true
  ):MarshalStruct<TTypeMarshal> {
    var cacheKey = Mangle.parts([
      (allocatable ? "a" : ""),
      name,
    ].concat(fields.map(field -> [
      field.name,
      field.type.mangled,
    ]).flatten()));
    if (cacheStruct.exists(cacheKey))
      return cacheStruct[cacheKey];

    var type = opaquePtr(name);
    var getters = new Map();
    var setters = new Map();
    var libExpr = library.typeDefExpr();
    for (field in fields) {
      if (field.read) {
        getters[field.name] = structPtrInternalFieldGetter(name, type, field);
      }
      if (field.write) {
        setters[field.name] = structPtrInternalFieldSetter(name, type, field);
      }
    }
    var nullPtrF = library.addFunction(
      type,
      [],
      '_return = ($name*)0;'
    );
    var nullPtr = macro $nullPtrF();
    var alloc = null;
    var free = null;
    if (allocatable) {
      var allocF = library.addFunction(
        type,
        [],
        '_return = ($name*)${library.config.callocFunction}(1, sizeof($name));'
      );
      var freeF = library.addFunction(
        void(),
        [type],
        new LineBuf()
          .lmapi(fields.filter(field -> field.owned), (idx, field)
            -> '${field.type.l2Type} _l2_field_$idx;
${field.type.l3l2('_arg0->${field.name}', '_l2_field_$idx')}
${field.type.l2unref('_l2_field_$idx')}')
          .ail('${library.config.freeFunction}(_arg0);')
          .done()
      );
      alloc = macro $allocF();
      free = (self) -> macro $freeF($self);
    }
    return cacheStruct[cacheKey] = {
      type: type,
      getters: getters,
      setters: setters,
      alloc: alloc,
      free: free,
      nullPtr: nullPtr,
    };
  }

  function structPtrInternalFieldGetter(
    structName:String,
    type:TTypeMarshal,
    field:BaseFieldRef<TTypeMarshal>
  ):(self:Expr)->Expr {
    var fname = field.name;
    var getterF = library.addFunction(
      field.type,
      [type],
      '_return = _arg0->${fname};'
    );
    return (self) -> macro $getterF($self);
  }

  function structPtrInternalFieldSetter(
    structName:String,
    type:TTypeMarshal,
    field:BaseFieldRef<TTypeMarshal>
  ):(self:Expr, val:Expr)->Expr {
    var fname = field.name;
    var setterF = library.addFunction(
      void(),
      [type, field.type],
      field.owned
        ? '${field.type.l2Type} _l2_old;
${field.type.l3l2('_arg0->${fname}', "_l2_old")}
${field.type.l2ref("_l2_arg_1")}
${field.type.l2unref("_l2_old")}
_arg0->${fname} = _arg1;'
        : '_arg0->${fname} = _arg1;'
    );
    return (self, val) -> macro $setterF($self, $val);
  }

  public function arrayPtr(element:TTypeMarshal):MarshalArray<TTypeMarshal> {
    if (cacheArray.exists(element.mangled))
      return cacheArray[element.mangled];

    // var cType = '${element.l3Type}*';
    var type = arrayPtrInternalType(element);
    var defaultArrayType = type.haxeType;
    var defaultElType = element.haxeType;
    var defaultVectorType = (macro : haxe.ds.Vector<$defaultElType>);

    var allocF = library.addFunction(
      type,
      [int32()],
      '_return = (${type.l3Type})${library.config.mallocFunction}(_arg0 * sizeof(${element.l3Type}));'
    );
    var alloc = (size) -> macro $allocF($size);

    var platform = (if (element.arrayType == null) {
      {
        vectorType: null,
        toHaxeCopy: null,
        fromHaxeCopy: null,
        toHaxeRef: null,
        fromHaxeRef: null,
      };
    } else {
      arrayPtrInternalOps(type, element, alloc);
    });

    var libExpr = library.typeDefExpr();
    var get = library.addFunction(element, [type, int32()], '_return = _arg0[_arg1];');
    var set = library.addFunction(void(), [type, int32(), element], '_arg0[_arg1] = _arg2;');
    var zalloc = library.addFunction(
      type,
      [int32()],
      '_return = (${type.l3Type})${library.config.callocFunction}(_arg0, sizeof(${element.l3Type}));'
    );
    var free = library.addFunction(
      void(),
      [type],
      '${library.config.freeFunction}(_arg0);'
    );
    return cacheArray[element.mangled] = {
      type: type,
      get: (self, index) -> macro $get($self, $index),
      set: (self, index, val) -> macro $set($self, $index, $val),
      alloc: alloc,
      zalloc: (size) -> macro $zalloc($size),
      free: (self) -> macro $free($self),

      vectorType: platform.vectorType,
      vectorTypePath: platform.vectorType != null ? TypeUtils.complexTypeToPath(platform.vectorType) : null,
      toHaxeCopy: platform.toHaxeCopy != null ? platform.toHaxeCopy : (self, size) -> macro {
        var _self = ($self : $defaultArrayType);
        var _size = ($size : Int);
        var _ret = new haxe.ds.Vector<$defaultElType>(_size);
        for (i in 0..._size) _ret[i] = $get(_self, i);
        _ret;
      },
      fromHaxeCopy: platform.fromHaxeCopy != null ? platform.fromHaxeCopy : (vector) -> macro {
        var _vector = ($vector : $defaultVectorType);
        var _ret = $allocF(_vector.length);
        for (i in 0..._vector.length) $set(_ret, i, _vector[i]);
        _ret;
      },
      toHaxeRef: platform.toHaxeRef,
      fromHaxeRef: platform.fromHaxeRef,
    };

    /*
    var type = bytesInternalType();

    var allocF = library.addFunction(
      type,
      [int32()],
      '_return = (uint8_t*)${library.config.mallocFunction}(_arg0);'
    );
    var alloc = (size) -> macro $allocF($size);
    var blitF = library.addFunction(
      void(),
      [type, int32(), type, int32(), int32()],
      '${library.config.memcpyFunction}(&_arg2[_arg3], &_arg0[_arg1], _arg4);'
    );
    var blit = (source, srcpos, dest, dstpos, size) -> macro $blitF($source, $srcpos, $dest, $dstpos, $size);
    var platform = bytesInternalOps(alloc, blit);

    var libExpr = library.typeDefExpr();
    var get8  = library.addFunction(uint8(),  [type, int32()], '_return = _arg0[_arg1];');
    var get16 = library.addFunction(uint16(), [type, int32()], '${library.config.memcpyFunction}(&_return, &_arg0[_arg1], 2);');
    var get32 = library.addFunction(uint32(), [type, int32()], '${library.config.memcpyFunction}(&_return, &_arg0[_arg1], 4);');
    var set8  = library.addFunction(void(), [type, int32(), uint8() ], '_arg0[_arg1] = _arg2;');
    var set16 = library.addFunction(void(), [type, int32(), uint16()], '${library.config.memcpyFunction}(&_arg0[_arg1], &_arg2, 2);');
    var set32 = library.addFunction(void(), [type, int32(), uint32()], '${library.config.memcpyFunction}(&_arg0[_arg1], &_arg2, 4);');
    var zalloc = library.addFunction(
      type,
      [int32()],
      '_return = (uint8_t*)${library.config.callocFunction}(_arg0, 1);'
    );
    // TODO: free should decref all owned fields
    var free = library.addFunction(
      void(),
      [type],
      '${library.config.freeFunction}(_arg0);'
    );
    var copy = library.addFunction(
      type,
      [type, int32()],
      '_return = (uint8_t*)${library.config.mallocFunction}(_arg1);
${library.config.memcpyFunction}(_return, _arg0, _arg1);'
    );
    return cacheBytes = {
      type: type,

      get8:  (self, index) -> macro $get8 ($self, $index),
      get16: (self, index) -> macro $get16($self, $index),
      get32: (self, index) -> macro $get32($self, $index),

      set8:  (self, index, val) -> macro $set8 ($self, $index, $val),
      set16: (self, index, val) -> macro $set16($self, $index, $val),
      set32: (self, index, val) -> macro $set32($self, $index, $val),

      alloc: alloc,
      zalloc: (size) -> macro $zalloc($size),
      free: (self) -> macro $free($self),
      copy: (self, size) -> macro $copy($self, $size),
      blit: blit,

      toBytesCopy: platform.toBytesCopy,
      fromBytesCopy: platform.fromBytesCopy,
      toBytesRef: platform.toBytesRef,
      fromBytesRef: platform.fromBytesRef,
    };
    */


    /*
    {
          type: type,

          get8:  (self, index) -> macro $get8 ($self, $index),
          get16: (self, index) -> macro $get16($self, $index),
          get32: (self, index) -> macro $get32($self, $index),

          set8:  (self, index, val) -> macro $set8 ($self, $index, $val),
          set16: (self, index, val) -> macro $set16($self, $index, $val),
          set32: (self, index, val) -> macro $set32($self, $index, $val),

          alloc: alloc,
          zalloc: (size) -> macro $zalloc($size),
          free: (self) -> macro $free($self),
          copy: (self, size) -> macro $copy($self, $size),
          blit: blit,

          toBytesCopy: platform.toBytesCopy,
          fromBytesCopy: platform.fromBytesCopy,
          toBytesRef: platform.toBytesRef,
          fromBytesRef: platform.fromBytesRef,
        }
*/
  }

  static function baseArrayPtrInternal(element:BaseTypeMarshal):BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
    l1Type: '${element.l2Type}*',
    l2Type: '${element.l2Type}*',
    l3Type: '${element.l3Type}*',
    mangled: 'a${Mangle.identifier(element.l3Type)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
  };
  function baseArrayRef(
    element:TTypeMarshal,
    vectorType:ComplexType,
    ptrType:ComplexType,
    nullPtr:Expr,
    handleType:ComplexType,
    nullHandle:Expr,
    unref:Expr
  ):TypePath {
    var tdefArrayRef = library.typeDefCreate();
    tdefArrayRef.name += '_ArrayRef_${element.mangled}';
    tdefArrayRef.fields = (macro class ArrayRef {
      public var vector(default, null):$vectorType;
      public var ptr(default, null):$ptrType;
      private var handle:$handleType;
      public function unref():Void {
        if (vector != null) {
          $unref;
          vector = null;
          ptr = $nullPtr;
          handle = $nullHandle;
        }
      }
      private function new(vector:$vectorType, ptr:$ptrType, handle:$handleType) {
        this.vector = vector;
        this.ptr = ptr;
        this.handle = handle;
      }
    }).fields;
    return {
      name: tdefArrayRef.name,
      pack: tdefArrayRef.pack,
    };
  }
  abstract function arrayPtrInternalType(element:TTypeMarshal):TTypeMarshal;
  function arrayPtrInternalOps(
    type:TTypeMarshal,
    element:TTypeMarshal,
    alloc:(size:Expr)->Expr
    // blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    vectorType:Null<ComplexType>,
    toHaxeCopy:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeCopy:Null<(array:Expr)->Expr>,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(array:Expr)->Expr>,
  } {
    return {
      vectorType: null,
      toHaxeCopy: null,
      fromHaxeCopy: null,
      toHaxeRef: null,
      fromHaxeRef: null,
    };
  }

  /*
  public function haxePtr(haxeType:haxe.macro.Type):TTypeMarshal {
    var cacheKey = Mangle.type(haxeType);
    if (cacheHaxe.exists(cacheKey))
      return cacheHaxe[cacheKey];
    return cacheHaxe[cacheKey] = haxePtrInternal(haxeType);
  }

  abstract function haxePtrInternal(haxeType:haxe.macro.Type):TTypeMarshal;
  */

  public function haxePtr(haxeType:ComplexType):TTypeMarshal {
    var cacheKey = Mangle.complexType(haxeType);
    if (cacheHaxe.exists(cacheKey))
      return cacheHaxe[cacheKey];
    return cacheHaxe[cacheKey] = haxePtrInternal(haxeType);
  }

  static function baseHaxePtrInternal(haxeType:ComplexType):BaseTypeMarshal return {
    haxeType: (macro : Dynamic),
    l1Type: "void*",
    l2Type: "void*",
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: MARSHAL_CONVERT_DIRECT,
  };
  abstract function haxePtrInternal(haxeType:ComplexType):TTypeMarshal;

  public function closure(ret:TTypeMarshal, args:Array<TTypeMarshal>):MarshalClosure<TTypeMarshal> {
    var cacheKey = Mangle.parts([ret.mangled].concat(args.map(arg -> arg.mangled)));
    if (cacheClosure.exists(cacheKey))
      return cacheClosure[cacheKey];
    return cacheClosure[cacheKey] = {
      type: haxePtr(TFunction(
        args.map(arg -> arg.haxeType),
        ret.haxeType
      )),
      ret: ret,
      args: args,
    };
  }
}

#end
