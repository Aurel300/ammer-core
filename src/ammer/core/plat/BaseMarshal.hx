package ammer.core.plat;

#if macro

import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

// TODO: add std.* prefix to `haxeType`s
abstract class BaseMarshal<
  TSelf:BaseMarshal<TSelf, TPlatform, TConfig, TLibraryConfig, TLibrary, TTypeMarshal>,
  TPlatform:Base<TPlatform, TConfig, TLibraryConfig, TTypeMarshal, TLibrary, TSelf>,
  TConfig:BaseConfig,
  TLibraryConfig:LibraryConfig,
  TLibrary:BaseLibrary<TLibrary, TPlatform, TConfig, TLibraryConfig, TTypeMarshal, TSelf>,
  TTypeMarshal:BaseTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';
  static final MARSHAL_CONVERT_CAST = (type:String) -> (src:String, dst:String) -> '$dst = ($type)$src;';
  static final MARSHAL_CONVERT_INT_TO_PTR = (src:String, dst:String) -> '$dst = (void*)(intptr_t)$src;';

  public var library:TLibrary;

  var cacheOpaque:Map<String, MarshalOpaque<TTypeMarshal>> = [];
  var cacheBox:Map<String, MarshalBox<TTypeMarshal>> = [];
  var cacheStruct:Map<String, MarshalStruct<TTypeMarshal>> = [];
  var cacheArray:Map<String, MarshalArray<TTypeMarshal>> = [];
  var cacheHaxe:Map<String, MarshalHaxe<TTypeMarshal>> = [];
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
    l2l3: MARSHAL_NOOP2,
    l3l2: MARSHAL_NOOP2,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2l1: MARSHAL_CONVERT_DIRECT,
    arrayBits: 3,
  };
  abstract public function float32():TTypeMarshal;
  abstract public function float64():TTypeMarshal;

  static function baseString():BaseTypeMarshal return {
    haxeType: (macro : std.String),
    l1Type: "const char*",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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

      toHaxeCopy: platform.toHaxeCopy,
      fromHaxeCopy: platform.fromHaxeCopy,
      toHaxeRef: platform.toHaxeRef,
      fromHaxeRef: platform.fromHaxeRef,
    };
  }

  static function baseBytesInternal():BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
    l1Type: "uint8_t*",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
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
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  };

  public function opaque(name:String):MarshalOpaque<TTypeMarshal> {
    if (cacheOpaque.exists(name))
      return cacheOpaque[name];
    return cacheOpaque[name] = opaqueInternal(name);
  }

  static function baseOpaquePtrInternal(name:String):BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
    l1Type: '$name*',
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2l1: MARSHAL_CONVERT_DIRECT,
  };
  static function baseOpaqueDirectInternal(name:String):BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
    l1Type: '$name*',
    l2Type: '$name*',
    l3Type: '$name',
    mangled: 'd${Mangle.identifier(name)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2l3: (l2, l3) -> '$l3 = *(($name*)$l2);',
    l3l2: (l3, l2) -> '$l2 = ($name*)(&($l3));',
    l2l1: MARSHAL_CONVERT_DIRECT,
  };
  abstract function opaqueInternal(name:String):MarshalOpaque<TTypeMarshal>;

  public function boxPtr(
    valueType:TTypeMarshal
  ):MarshalBox<TTypeMarshal> {
    // TODO: check valueType is primitive
    if (cacheBox.exists(valueType.mangled))
      return cacheBox[valueType.mangled];

    var types = opaque(valueType.l3Type);
    var get = library.addFunction(
      valueType,
      [types.type],
      '_return = *_arg0;'
    );
    var set = library.addFunction(
      void(),
      [types.type, valueType],
      '*_arg0 = _arg1;'
    );
    var nullPtr = library.addFunction(
      types.type,
      [],
      '_return = (${valueType.l3Type}*)0;'
    );
    var alloc = library.addFunction(
      types.type,
      [],
      '_return = (${valueType.l3Type}*)${library.config.callocFunction}(1, sizeof(${valueType.l3Type}));'
    );
    var free = library.addFunction(
      void(),
      [types.type],
      '${library.config.freeFunction}(_arg0);'
    );

    return cacheBox[valueType.mangled] = {
      type: types.type,
      get: (self) -> macro $get($self),
      set: (self, val) -> macro $set($self, $val),
      alloc: macro $alloc(),
      free: (self) -> macro $free($self),
      nullPtr: macro $nullPtr(),
    };
  }

  public function structPtr(
    name:String,
    fields:Array<BaseFieldRef<TTypeMarshal>>,
    allocatable:Bool = true
  ):MarshalStruct<TTypeMarshal> {
    var cacheKey = Mangle.parts([
      (allocatable ? "a" : ""),
      name,
    ].concat(fields.map(field -> [
      field.type.mangled,
      field.name,
    ]).flatten()));
    if (cacheStruct.exists(cacheKey))
      return cacheStruct[cacheKey];

    var types = opaque(name);
    var fieldGet = new Map();
    var fieldSet = new Map();
    var fieldRef = new Map();
    var libExpr = library.typeDefExpr();
    for (field in fields) {
      if (field.read == null || field.read) {
        fieldGet[field.name] = structPtrInternalFieldGetter(name, types.type, field);
      }
      if (field.write == null || field.write) {
        fieldSet[field.name] = structPtrInternalFieldSetter(name, types.type, field);
      }
      if (field.ref == null || field.ref) {
        fieldRef[field.name] = structPtrInternalFieldReffer(name, types.type, {
          name: field.name,
          type: boxPtr(field.type).type,
          // others should not be needed (unless structPtrInternalFieldReffer
          // is overridden weirdly)
        });
      }
    }
    var nullPtrF = library.addFunction(
      types.type,
      [],
      '_return = ($name*)0;'
    );
    var nullPtr = macro $nullPtrF();
    var alloc = null;
    var free = null;
    var clone = null;
    if (allocatable) {
      var allocF = library.addFunction(
        types.type,
        [],
        '_return = ($name*)${library.config.callocFunction}(1, sizeof($name));'
      );
      var freeF = library.addFunction(
        void(),
        [types.type],
        '${library.config.freeFunction}(_arg0);'
      );
      var cloneF = library.addFunction(
        types.type,
        [types.type],
        '_return = ($name*)${library.config.callocFunction}(1, sizeof($name));
${library.config.memcpyFunction}(_return, _arg0, sizeof($name));'
      );
      alloc = macro $allocF();
      free = (self) -> macro $freeF($self);
      clone = (self) -> macro $cloneF($self);
    }
    return cacheStruct[cacheKey] = {
      type: types.type,
      typeDeref: types.typeDeref,
      fieldGet: fieldGet,
      fieldSet: fieldSet,
      fieldRef: fieldRef,
      alloc: alloc,
      free: free,
      clone: clone,
      nullPtr: nullPtr,
    };
  }

  function structPtrInternalFieldReffer(
    structName:String,
    type:TTypeMarshal,
    field:BaseFieldRef<TTypeMarshal>
  ):(self:Expr)->Expr {
    var fname = field.name;
    var refferF = library.addFunction(
      field.type,
      [type],
      "",
      {
        l3Return: '&_arg0->${fname}',
      }
    );
    return (self) -> macro $refferF($self);
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
      "",
      {
        // L3 return directly pointing to field, so that nested structs are not
        // copied out when referencing
        l3Return: '_arg0->${fname}',
      }
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
      '_arg0->${fname} = _arg1;'
    );
    return (self, val) -> macro $setterF($self, $val);
  }

  public function arrayPtr(element:TTypeMarshal):MarshalArray<TTypeMarshal> {
    var cacheKey = element.mangled;
    if (cacheArray.exists(cacheKey))
      return cacheArray[cacheKey];

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
    var get = arrayPtrInternalGetter(type, element);
    var set = arrayPtrInternalSetter(type, element);
    var ref = arrayPtrInternalReffer(type, boxPtr(element).type);
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
    return cacheArray[cacheKey] = {
      type: type,
      get: get,
      set: set,
      ref: ref,
      alloc: alloc,
      zalloc: (size) -> macro $zalloc($size),
      free: (self) -> macro $free($self),

      vectorType: platform.vectorType,
      vectorTypePath: platform.vectorType != null ? TypeUtils.complexTypeToPath(platform.vectorType) : null,
      toHaxeCopy: platform.toHaxeCopy != null ? platform.toHaxeCopy : (self, size) -> macro {
        var _self = ($self : $defaultArrayType);
        var _size = ($size : Int);
        var _ret = new haxe.ds.Vector<$defaultElType>(_size);
        for (i in 0..._size) _ret[i] = $e{get(macro _self, macro i)};
        _ret;
      },
      fromHaxeCopy: platform.fromHaxeCopy != null ? platform.fromHaxeCopy : (vector) -> macro {
        var _vector = ($vector : $defaultVectorType);
        var _ret = $allocF(_vector.length);
        for (i in 0..._vector.length) $e{set(macro _ret, macro i, macro _vector[i])};
        _ret;
      },
      toHaxeRef: platform.toHaxeRef,
      fromHaxeRef: platform.fromHaxeRef,
    };
  }

  function arrayPtrInternalReffer(
    type:TTypeMarshal,
    element:TTypeMarshal
  ):(self:Expr, index:Expr)->Expr {
    var refferF = library.addFunction(
      element,
      [type, int32()],
      "",
      {
        l3Return: "&_arg0[_arg1]",
      });
    return (self, index) -> macro $refferF($self, $index);
  }

  function arrayPtrInternalGetter(
    type:TTypeMarshal,
    element:TTypeMarshal
  ):(self:Expr, index:Expr)->Expr {
    var getterF = library.addFunction(
      element,
      [type, int32()],
      "",
      {
        // L3 return directly pointing to index, so that nested structs are not
        // copied out when referencing
        l3Return: "_arg0[_arg1]",
      });
    return (self, index) -> macro $getterF($self, $index);
  }

  function arrayPtrInternalSetter(
    type:TTypeMarshal,
    element:TTypeMarshal
  ):(self:Expr, index:Expr, val:Expr)->Expr {
    var setterF = library.addFunction(
      void(),
      [type, int32(), element],
      "_arg0[_arg1] = _arg2;"
    );
    return (self, index, val) -> macro $setterF($self, $index, $val);
  }

  static function baseArrayPtrInternal(element:BaseTypeMarshal):BaseTypeMarshal return {
    haxeType: (macro : Void), // must be overridden
    l1Type: '${element.l1Type}*', // L2?
    l2Type: '${element.l2Type}*',
    l3Type: '${element.l3Type}*',
    mangled: 'a${Mangle.identifier(element.l3Type)}_',
    l1l2: MARSHAL_CONVERT_CAST('${element.l2Type}*'),
    l2l3: MARSHAL_CONVERT_CAST('${element.l3Type}*'),
    l3l2: MARSHAL_CONVERT_CAST('${element.l2Type}*'),
    l2l1: MARSHAL_CONVERT_CAST('${element.l1Type}*'),
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

  /*
  public function haxePtr(haxeType:ComplexType):TTypeMarshal {
    var cacheKey = Mangle.complexType(haxeType);
    if (cacheHaxe.exists(cacheKey))
      return cacheHaxe[cacheKey];
    return cacheHaxe[cacheKey] = haxePtrInternal(haxeType);
  }
*/

  public function haxePtr(haxeType:ComplexType):MarshalHaxe<TTypeMarshal> {
    var cacheKey = Mangle.complexType(haxeType);
    if (cacheHaxe.exists(cacheKey))
      return cacheHaxe[cacheKey];
    return cacheHaxe[cacheKey] = haxePtrInternal(haxeType);
  }

  function baseHaxePtrInternal(
    // TODO: clean up interface
    haxeType:ComplexType,
    handleType:ComplexType,
    nullHandle:Expr,
    getValue:Expr,
    getRefCount:Expr,
    setRefCount:(rc:Expr)->Expr,
    createRef:(value:Expr)->Expr,
    delRef:Expr,
    ?extraFields:Array<Field>,
    ?isNullHandle:(handle:Expr)->Expr
  ):{
    tdef:TypeDefinition,
    marshal:MarshalHaxe<TTypeMarshal>,
    mangled:String,
  } {
    var mangled = 'h${Mangle.complexType(haxeType)}_';

    var tdefRef = library.typeDefCreate();
    tdefRef.name += '_HaxeRef_$mangled';
    var tp = {
      name: tdefRef.name,
      pack: tdefRef.pack,
    };
    var ct = TPath(tp);
    // TODO: could be an abstract?
    var nullCheck = isNullHandle == null
      ? macro handle == $nullHandle
      : isNullHandle(macro handle);
    tdefRef.fields = (macro class HaxeRef {
      public var handle(default, null):$handleType;
      public var value(get, never):$haxeType;
      public var refCount(get, never):Int;

      inline function get_value():$haxeType {
        return $getValue;
      }
      inline function get_refCount():Int {
        return $getRefCount;
      }

      public function incref():Void {
        // TODO: do in a single call?
        var rc = $getRefCount + 1;
        $e{setRefCount(macro rc)};
      }
      public function decref():Void {
        // TODO: do in a single call?
        var rc = $getRefCount + 1;
        if (rc <= 0) {
          $delRef;
          handle = $nullHandle;
        }
      }
      private static function create(value:$haxeType):$ct {
        var handle = $e{createRef(macro value)};
        return new $tp(handle);
      }
      private static function restore(handle:$handleType):Null<$ct> {
        if ($nullCheck) return null;
        return new $tp(handle);
      }
      private function new(handle:$handleType) {
        this.handle = handle;
      }
    }).fields.concat(extraFields != null ? extraFields : []);

    return {
      tdef: tdefRef,
      marshal: {
        type: haxePtrInternalType(haxeType),
        create: (val) -> macro @:privateAccess $p{tp.pack.concat([tp.name])}.create($val),
        restore: (handle) -> macro @:privateAccess $p{tp.pack.concat([tp.name])}.restore($handle),
      },
      mangled: mangled,
    };
  }
  abstract function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<TTypeMarshal>;

  static function baseHaxePtrInternalType(haxeType:ComplexType):BaseTypeMarshal return {
    haxeType: haxeType,
    l1Type: "void*",
    l2Type: "void*",
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_CONVERT_DIRECT,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2l1: MARSHAL_CONVERT_DIRECT,
  };
  abstract function haxePtrInternalType(haxeType:ComplexType):TTypeMarshal;

  public function closure(ret:TTypeMarshal, args:Array<TTypeMarshal>):MarshalClosure<TTypeMarshal> {
    var cacheKey = Mangle.parts([ret.mangled].concat(args.map(arg -> arg.mangled)));
    if (cacheClosure.exists(cacheKey))
      return cacheClosure[cacheKey];
    var type = haxePtr(TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ));
    return cacheClosure[cacheKey] = {
      type: type.type,
      create: type.create,
      restore: type.restore,
      ret: ret,
      args: args,
    };
  }
}

#end
