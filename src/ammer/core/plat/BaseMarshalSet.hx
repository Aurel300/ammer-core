package ammer.core.plat;

#if macro

import haxe.macro.Expr;
import ammer.core.utils.*;

using Lambda;

// TODO: generic over field refs?
abstract class BaseMarshalSet<
  TSelf:BaseMarshalSet<TSelf, TLibraryConfig, TLibrary, TTypeMarshal>,
  TLibraryConfig:LibraryConfig,
  TLibrary:BaseLibrary<TLibrary, TLibraryConfig, TTypeMarshal, TSelf>,
  TTypeMarshal:BaseTypeMarshal
> {
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

  abstract public function void():TTypeMarshal;

  abstract public function bool():TTypeMarshal;

  abstract public function uint8():TTypeMarshal;
  abstract public function int8():TTypeMarshal;
  abstract public function uint16():TTypeMarshal;
  abstract public function int16():TTypeMarshal;
  abstract public function uint32():TTypeMarshal;
  abstract public function int32():TTypeMarshal;
  abstract public function uint64():TTypeMarshal;
  abstract public function int64():TTypeMarshal;

  abstract public function float32():TTypeMarshal;
  abstract public function float64():TTypeMarshal;

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
    var platform = bytesInternalOps(type, alloc, blit);

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

      toBytesCopy: platform.toBytesCopy,
      fromBytesCopy: platform.fromBytesCopy,
      toBytesRef: platform.toBytesRef,
      fromBytesRef: platform.fromBytesRef,
    };
  }

  // TODO: this is a bit ugly (first calling platform for type, then for ops)
  abstract function bytesInternalType():TTypeMarshal;
  abstract function bytesInternalOps(
    type:TTypeMarshal,
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
    return cacheStruct[cacheKey] = structPtrInternal(name, fields, allocatable);
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

  function structPtrInternal(
    name:String,
    fields:Array<BaseFieldRef<TTypeMarshal>>,
    allocatable:Bool = true
  ):MarshalStruct<TTypeMarshal> {
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
    return {
      type: type,
      getters: getters,
      setters: setters,
      alloc: alloc,
      free: free,
      nullPtr: nullPtr,
    };
  }

  public function arrayPtr(element:TTypeMarshal):MarshalArray<TTypeMarshal> {
    if (cacheArray.exists(element.mangled))
      return cacheArray[element.mangled];
    var cType = '${element.l3Type}*';
    var type = opaquePtr(element.l3Type); // TODO? (should be fine?)
    var libExpr = library.typeDefExpr();
    var get = library.addFunction(
      element,
      [type, int32()],
      '_return = _arg0[_arg1];'
    );
    var set = library.addFunction(
      void(),
      [type, int32(), element],
      '_arg0[_arg1] = _arg2;'
    );
    var alloc = library.addFunction(
      type,
      [int32()],
      '_return = ($cType)${library.config.callocFunction}(_arg0, sizeof(${element.l3Type}));'
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
      alloc: (size) -> macro $alloc($size),
      free: (self) -> macro $free($self),
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

  abstract function haxePtrInternal(haxeType:ComplexType):TTypeMarshal;

  public function closure(ret:TTypeMarshal, args:Array<TTypeMarshal>):MarshalClosure<TTypeMarshal> {
    var cacheKey = Mangle.parts([ret.mangled].concat(args.map(arg -> arg.mangled)));
    if (cacheClosure.exists(cacheKey))
      return cacheClosure[cacheKey];
    return cacheClosure[cacheKey] = {
      type: closureInternal(ret, args),
      ret: ret,
      args: args,
    };
  }

  abstract function closureInternal(ret:TTypeMarshal, args:Array<TTypeMarshal>):TTypeMarshal;
}

#end
