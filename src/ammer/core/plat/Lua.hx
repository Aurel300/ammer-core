package ammer.core.plat;

#if macro

@:structInit
class LuaConfig extends BaseConfig {
  public var luaIncludePaths:Array<String> = null;
  public var luaLibraryPaths:Array<String> = null;
}

typedef LuaLibraryConfig = LibraryConfig;

typedef LuaTypeMarshal = BaseTypeMarshal;

class Lua extends Base<
  Lua,
  LuaConfig,
  LuaLibraryConfig,
  LuaTypeMarshal,
  LuaLibrary,
  LuaMarshal
> {
  public function new(config:LuaConfig) {
    super("lua", config);
  }

  public function createLibrary(libConfig:LuaLibraryConfig):LuaLibrary {
    return new LuaLibrary(this, libConfig);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.luaIncludePaths,
      libraryPaths: config.luaLibraryPaths,
      // TODO: version, configure, etc
      linkNames: [BuildProgram.useMSVC ? "lua53" : "lua"],
    });
  }
}

@:allow(ammer.core.plat)
class LuaLibrary extends BaseLibrary<
  LuaLibrary,
  Lua,
  LuaConfig,
  LuaLibraryConfig,
  LuaTypeMarshal,
  LuaMarshal
> {
  var lbInit = new LineBuf();

  public function new(platform:Lua, config:LuaLibraryConfig) {
    super(platform, config, new LuaMarshal(this));
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : lua.Table<String, Dynamic>),
        macro {
          var loadlib = (switch (Sys.systemName()) {
            case "Windows": $v{config.name} + ".dll";
            case "Mac": "lib" + $v{config.name} + ".dylib";
            case _: "lib" + $v{config.name} + ".so";
          });
          untyped __lua__('assert(package.loadlib({0}, "_ammer_init"))()', loadlib);
        }
      ),
      access: [APrivate, AStatic],
    });
    // TODO: internalPrefix
    lb.ail('#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

static int32_t _ammer_ctr = 0;
static const char *_ammer_registry_name = "${config.internalPrefix}registry";
static lua_State* _ammer_lua_state; // TODO: multiple threads?
typedef struct { int32_t value; int32_t refcount; } _ammer_haxe_ref;
static int _ammer_ref_create(lua_State* _lua_state) {
  int32_t idx = _ammer_ctr++;
  lua_pushstring(_lua_state, _ammer_registry_name);
  lua_gettable(_lua_state, LUA_REGISTRYINDEX);
  lua_pushinteger(_lua_state, idx);
  lua_pushvalue(_lua_state, 1);
  lua_settable(_lua_state, -3);
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)${config.mallocFunction}(sizeof(_ammer_haxe_ref));
  ref->value = idx;
  ref->refcount = 0;
  lua_pushlightuserdata(_lua_state, ref);
  return 1;
}
static int _ammer_ref_delete(lua_State* _lua_state) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)lua_touserdata(_lua_state, 1);
  lua_pushstring(_lua_state, _ammer_registry_name);
  lua_gettable(_lua_state, LUA_REGISTRYINDEX);
  lua_pushinteger(_lua_state, ref->value);
  lua_pushnil(_lua_state);
  lua_settable(_lua_state, -3);
  ref->value = 0;
  ${config.freeFunction}(ref);
  return 0;
}
static int _ammer_ref_getcount(lua_State* _lua_state) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)lua_touserdata(_lua_state, 1);
  lua_pushinteger(_lua_state, ref->refcount);
  return 1;
}
static int _ammer_ref_setcount(lua_State* _lua_state) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)lua_touserdata(_lua_state, 1);
  int32_t rc = lua_tointeger(_lua_state, 2);
  ref->refcount = rc;
  return 0;
}
static int _ammer_ref_getvalue(lua_State* _lua_state) {
  _ammer_haxe_ref* ref = (_ammer_haxe_ref*)lua_touserdata(_lua_state, 1);
  lua_pushstring(_lua_state, _ammer_registry_name);
  lua_gettable(_lua_state, LUA_REGISTRYINDEX);
  lua_pushinteger(_lua_state, ref->value);
  lua_gettable(_lua_state, -2);
  return 1;
}
');
    /*
    lb.ail(""); 
    lb.ail('static const char *_ammer_registry_name = "${config.internalPrefix}registry";');
    boilerplate(
      "void*",
      "const void*",
      "size_t stored;",
      "",
      "lua_State* _lua_state = _ammer_core_registry.ctx;
lua_pushstring(_lua_state, _ammer_registry_name);
lua_gettable(_lua_state, LUA_REGISTRYINDEX);
lua_pushinteger(_lua_state, curr->stored);
lua_pushnil(_lua_state);
lua_settable(_lua_state, -3);"
    );
    */
  }

  override function finalise(platConfig:LuaConfig):Void {
    // TODO: name symbols with internalPrefix
    lb.ail('
static int _ammer_lua_tobytesdata(lua_State* _lua_state) {
  uint8_t* data = lua_touserdata(_lua_state, 1);
  uint32_t size = lua_tointeger(_lua_state, 2);
  lua_createtable(_lua_state, size, 0);
  for (int i = 0; i < size; i++) {
    lua_pushinteger(_lua_state, i + 1);
    lua_pushinteger(_lua_state, data[i]);
    lua_settable(_lua_state, 3);
  }
  return 1;
}
static int _ammer_lua_frombytesdata(lua_State* _lua_state) {
  // in the stack we get a table (+ size for now? can be determined maybe?)
  // we need to create a lightuserdata
  uint32_t size = lua_tointeger(_lua_state, 2);
  uint8_t* data = (uint8_t*)${config.mallocFunction}(size); // TODO: check NULL
  for (int i = 0; i < size; i++) {
    lua_pushinteger(_lua_state, i + 1);
    lua_gettable(_lua_state, 1);
    data[i] = lua_tointeger(_lua_state, 3);
    lua_pop(_lua_state, 1);
  }
  lua_pushlightuserdata(_lua_state, data);
  return 1;
}
int _ammer_init(lua_State* _lua_state) {
  luaL_Reg _init_wrap[] = {
').addBuf(lbInit).ail('
    {"_ammer_lua_tobytesdata", _ammer_lua_tobytesdata},
    {"_ammer_lua_frombytesdata", _ammer_lua_frombytesdata},
    {"_ammer_ref_create", _ammer_ref_create},
    {"_ammer_ref_delete", _ammer_ref_delete},
    {"_ammer_ref_getcount", _ammer_ref_getcount},
    {"_ammer_ref_setcount", _ammer_ref_setcount},
    {"_ammer_ref_getvalue", _ammer_ref_getvalue},
    {NULL, NULL}
  };
  lua_newtable(_lua_state);
  luaL_setfuncs(_lua_state, _init_wrap, 0);
  lua_pushstring(_lua_state, _ammer_registry_name);
  lua_newtable(_lua_state);
  lua_settable(_lua_state, LUA_REGISTRYINDEX);
  _ammer_lua_state = _lua_state;
  return 1;
}');
    super.finalise(platConfig);
  }

  public function addNamedFunction(
    name:String,
    ret:LuaTypeMarshal,
    args:Array<LuaTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr {
    lb
      .ail('static int ${name}(lua_State* _lua_state) {')
      .i();
    baseAddNamedFunction(
      args,
      args.mapi((idx, arg) -> '${idx + 1}'),
      ret,
      "",
      code,
      lb,
      options
    );
    lb
        .ifi(ret.mangled != "v")
          .ail('return 1;')
        .ife()
          .ail("return 0;")
        .ifd()
      .d()
      .ail("}");
    lbInit.ail('{"${name}", ${name}},');
    var funcType = TFunction(args.map(arg -> arg.haxeType), ret.haxeType);
    // TODO: position?
    return macro ((untyped $e{fieldExpr("_ammer_native")}[$v{name}]) : $funcType);
  }

  public function closureCall(
    fn:String,
    clType:MarshalClosure<LuaTypeMarshal>,
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
        // first the function is restored and pushed
        .ail('${clType.type.l2l1("_l2_fn", "")}
int _l1_fn_idx = ((_ammer_haxe_ref*)lua_touserdata(_lua_state, -1))->value;
lua_pop(_lua_state, 1);
lua_pushstring(_lua_state, _ammer_registry_name);
lua_gettable(_lua_state, LUA_REGISTRYINDEX);
lua_pushinteger(_lua_state, _l1_fn_idx);
lua_gettable(_lua_state, -2);')
        // then the arguments in direct order
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', ""))
        .ail('lua_call(_lua_state, ${args.length}, 1);')
        .ifi(clType.ret.mangled != "v")
          .ail('${clType.ret.l2Type} _l2_output;')
          .ail(clType.ret.l1l2("-1", "_l2_output"))
          .ail(clType.ret.l2l3("_l2_output", outputExpr))
          .ail("lua_pop(_lua_state, 1);")
        .ifd()
      .d()
      .ail("} while (0);")
      .done();
  }

  public function addCallback(
    ret:LuaTypeMarshal,
    args:Array<LuaTypeMarshal>,
    code:String
  ):String {
    var name = mangleFunction(ret, args, code, "cb");
    lb
      .ai('static ${ret.l3Type} ${name}(')
      .mapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx}', ", ")
      .a(args.length == 0 ? "void" : "")
      .al(") {")
      .i()
        .ail('lua_State* _lua_state = _ammer_lua_state;')
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
class LuaMarshal extends BaseMarshal<
  LuaMarshal,
  Lua,
  LuaConfig,
  LuaLibraryConfig,
  LuaLibrary,
  LuaTypeMarshal
> {
  /*
  // TODO: ${config.internalPrefix}
  // TODO: this already roots
  static final MARSHAL_REGISTRY_GET_NODE = (l1:String, l2:String)
    -> '$l2 = _ammer_core_registry_get(lua_topointer(_lua_state, $l1));
$l2->stored = _ammer_ctr++;
lua_pushstring(_lua_state, _ammer_registry_name);
lua_gettable(_lua_state, LUA_REGISTRYINDEX);
lua_pushinteger(_lua_state, $l2->stored);
lua_pushvalue(_lua_state, $l1);
lua_settable(_lua_state, -3);
lua_pop(_lua_state, 1);';
  static final MARSHAL_REGISTRY_REF = (l2:String)
    -> '_ammer_core_registry_incref($l2);';
  static final MARSHAL_REGISTRY_UNREF = (l2:String)
    -> '_ammer_core_registry_decref($l2);';
  static final MARSHAL_REGISTRY_GET_KEY = MARSHAL_PUSH((l2:String) // TODO: target type cast
    -> 'lua_pushstring(_lua_state, _ammer_registry_name);
lua_gettable(_lua_state, LUA_REGISTRYINDEX);
lua_pushinteger(_lua_state, $l2->stored);
lua_gettable(_lua_state, -2);
lua_remove(_lua_state, -2);');
  */
  static final MARSHAL_PUSH = (l2push:String->String) -> (l2:String, l1:String) -> {
    if (l1 != "") throw 0; // in L2->L1 we can push onto the top of the stack
    l2push(l2);
  };

  static function baseExtend(
    base:BaseTypeMarshal,
    ?over:BaseTypeMarshal.BaseTypeMarshalOpt
  ):LuaTypeMarshal {
    return {
      haxeType:  over != null && over.haxeType  != null ? over.haxeType  : base.haxeType,
      // L1 type is always "int", representing a stack offset
      l1Type:   "int",
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

  static final MARSHAL_VOID = BaseMarshal.baseVoid();
  public function void():LuaTypeMarshal return MARSHAL_VOID;

  static final MARSHAL_BOOL = baseExtend(BaseMarshal.baseBool(), {
    l1l2: (l1, l2) -> '$l2 = lua_toboolean(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushboolean(_lua_state, $l2);'),
  });
  public function bool():LuaTypeMarshal return MARSHAL_BOOL;

  static final MARSHAL_UINT8 = baseExtend(BaseMarshal.baseUint8(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  static final MARSHAL_INT8 = baseExtend(BaseMarshal.baseInt8(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  static final MARSHAL_UINT16 = baseExtend(BaseMarshal.baseUint16(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  static final MARSHAL_INT16 = baseExtend(BaseMarshal.baseInt16(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  static final MARSHAL_UINT32 = baseExtend(BaseMarshal.baseUint32(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  static final MARSHAL_INT32 = baseExtend(BaseMarshal.baseInt32(), {
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushinteger(_lua_state, $l2);'),
  });
  public function uint8():LuaTypeMarshal return MARSHAL_UINT8;
  public function int8():LuaTypeMarshal return MARSHAL_INT8;
  public function uint16():LuaTypeMarshal return MARSHAL_UINT16;
  public function int16():LuaTypeMarshal return MARSHAL_INT16;
  public function uint32():LuaTypeMarshal return MARSHAL_UINT32;
  public function int32():LuaTypeMarshal return MARSHAL_INT32;

  static final MARSHAL_UINT64 = baseExtend(BaseMarshal.baseUint64(), {
    l1l2: (l1, l2) -> 'lua_getfield(_lua_state, $l1, "high");
lua_getfield(_lua_state, $l1, "low");
$l2 = ((uint64_t)lua_tointeger(_lua_state, -2) << 32) | (uint32_t)lua_tointeger(_lua_state, -1);
lua_pop(_lua_state, 2);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_createtable(_lua_state, 0, 2);
lua_pushinteger(_lua_state, (int32_t)($l2 & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "low");
lua_pushinteger(_lua_state, (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "high");'),
  });
  static final MARSHAL_INT64  = baseExtend(BaseMarshal.baseInt64(), {
    l1l2: (l1, l2) -> 'lua_getfield(_lua_state, $l1, "high");
lua_getfield(_lua_state, $l1, "low");
$l2 = ((int64_t)lua_tointeger(_lua_state, -2) << 32) | (uint32_t)lua_tointeger(_lua_state, -1);
lua_pop(_lua_state, 2);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_createtable(_lua_state, 0, 2);
lua_pushinteger(_lua_state, (int32_t)($l2 & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "low");
lua_pushinteger(_lua_state, (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "high");'),
  });
  public function uint64():LuaTypeMarshal return MARSHAL_UINT64;
  public function int64():LuaTypeMarshal return MARSHAL_INT64;

  static final MARSHAL_FLOAT32 = baseExtend(BaseMarshal.baseFloat64As32(), {
    l1l2: (l1, l2) -> '$l2 = lua_tonumber(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushnumber(_lua_state, $l2);'),
  });
  static final MARSHAL_FLOAT64 = baseExtend(BaseMarshal.baseFloat64(), {
    l1l2: (l1, l2) -> '$l2 = lua_tonumber(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushnumber(_lua_state, $l2);'),
  });
  public function float32():LuaTypeMarshal return MARSHAL_FLOAT32;
  public function float64():LuaTypeMarshal return MARSHAL_FLOAT64;

  static final MARSHAL_STRING = baseExtend(BaseMarshal.baseString(), {
    l1l2: (l1, l2) -> '$l2 = lua_tostring(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushstring(_lua_state, $l2);'),
  });
  public function string():LuaTypeMarshal return MARSHAL_STRING;

  static final MARSHAL_BYTES = baseExtend(BaseMarshal.baseBytesInternal(), {
    haxeType: (macro : lua.UserData),
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushlightuserdata(_lua_state, $l2);'),
  });
  function bytesInternalType():LuaTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toHaxeCopy:(self:Expr, size:Expr)->Expr,
    fromHaxeCopy:(bytes:Expr)->Expr,
    toHaxeRef:Null<(self:Expr, size:Expr)->Expr>,
    fromHaxeRef:Null<(bytes:Expr)->Expr>,
  } {
    // TODO: haxe.io.BytesData on Lua is Array<Int>, it really could be
    // the (native) String type, as it supports 0-bytes and need not be UTF-8
    return {
      toHaxeCopy: (self, size) -> macro {
        var _self = ($self : lua.UserData);
        var _size = ($size : Int);
        var _data = ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_lua_tobytesdata"]) : (lua.UserData, Int) -> lua.Table<Int, Int>)(
          _self,
          _size
        );
        haxe.io.Bytes.ofData(lua.Table.toArray(_data)); // TODO: avoid this re-copy
      },
      fromHaxeCopy: (bytes) -> macro {
        var _bytes = ($bytes : haxe.io.Bytes);
        var _ret = ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_lua_frombytesdata"]) : (lua.Table<Int, Int>, Int) -> lua.UserData)(
          lua.Table.fromArray(_bytes.getData()), // TODO: avoid this re-copy
          _bytes.length
        );
        (_ret : lua.UserData);
      },

      // TODO: maybe ref bytes could be simulated by creating a type that has
      // the same API as haxe.io.Bytes (and would have that type Haxe-side) but
      // internally refers to the userdata for any operations?
      toHaxeRef: null,
      fromHaxeRef: null,
    };
  }

  function opaqueInternal(name:String):LuaTypeMarshal return baseExtend(BaseMarshal.baseOpaqueInternal(name), {
    haxeType: (macro : lua.UserData),
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushlightuserdata(_lua_state, $l2);'),
  });

  function structPtrDerefInternal(name:String):LuaTypeMarshal return baseExtend(BaseMarshal.baseStructPtrDerefInternal(name), {
    haxeType: (macro : lua.UserData),
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushlightuserdata(_lua_state, $l2);'),
  });

  function arrayPtrInternalType(element:LuaTypeMarshal):LuaTypeMarshal return baseExtend(BaseMarshal.baseArrayPtrInternal(element), {
    haxeType: (macro : lua.UserData),
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'lua_pushlightuserdata(_lua_state, $l2);'),
  });

  function haxePtrInternal(haxeType:ComplexType):MarshalHaxe<LuaTypeMarshal> {
    var ret = baseHaxePtrInternal(
      haxeType,
      (macro : lua.UserData),
      macro null,
      macro ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_ref_getvalue"]) : (lua.UserData) -> $haxeType)(handle),
      macro ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_ref_getcount"]) : (lua.UserData) -> Int)(handle),
      rc -> macro ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_ref_setcount"]) : (lua.UserData, Int) -> Void)(handle, $rc),
      value -> macro ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_ref_create"]) : ($haxeType) -> lua.UserData)($value),
      macro ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_ref_delete"]) : (lua.UserData) -> Void)(handle)
    );
    TypeUtils.defineType(ret.tdef);
    return ret.marshal;
  }

  function haxePtrInternalType(haxeType:ComplexType):LuaTypeMarshal return baseExtend(BaseMarshal.baseHaxePtrInternalType(haxeType), {
    haxeType: (macro : lua.UserData),
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2l1: MARSHAL_PUSH((l2) -> 'if ($l2 == NULL) {
  lua_pushnil(_lua_state);
} else {
  lua_pushlightuserdata(_lua_state, $l2);
}'),
  });

  public function new(library:LuaLibrary) {
    super(library);
  }
}

#end
