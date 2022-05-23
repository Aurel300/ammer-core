package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.*;

@:allow(ammer.core.plat.Lua)
class LuaMarshalSet extends BaseMarshalSet<
  LuaMarshalSet,
  LuaLibraryConfig,
  LuaLibrary,
  LuaTypeMarshal
> {
  static final MARSHAL_NOOP1 = (_:String) -> "";
  static final MARSHAL_NOOP2 = (_:String, _:String) -> "";
  static final MARSHAL_CONVERT_DIRECT = (src:String, dst:String) -> '$dst = $src;';

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
  static final MARSHAL_REGISTRY_GET_KEY = (l2:String, l1:String) // TODO: target type cast
    -> 'lua_pushstring(_lua_state, _ammer_registry_name);
lua_gettable(_lua_state, LUA_REGISTRYINDEX);
lua_pushinteger(_lua_state, $l2->stored);
lua_gettable(_lua_state, -2);
lua_remove(_lua_state, -2);';

  static final MARSHAL_VOID:LuaTypeMarshal = {
    haxeType: (macro : Void),
    l1Type: "int",
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

  static final MARSHAL_BOOL:LuaTypeMarshal = {
    haxeType: (macro : Bool),
    l1Type: "int",
    l2Type: "bool",
    l3Type: "bool",
    mangled: "u1",
    l1l2: (l1, l2) -> '$l2 = lua_toboolean(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushboolean(_lua_state, $l2);',
  };

  static final MARSHAL_UINT8:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "uint8_t",
    l3Type: "uint8_t",
    mangled: "u8",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_INT8:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "int8_t",
    l3Type: "int8_t",
    mangled: "i8",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_UINT16:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "uint16_t",
    l3Type: "uint16_t",
    mangled: "u16",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_INT16:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "int16_t",
    l3Type: "int16_t",
    mangled: "i16",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_UINT32:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "uint32_t",
    l3Type: "uint32_t",
    mangled: "u32",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_INT32:LuaTypeMarshal = {
    haxeType: (macro : Int),
    l1Type: "int",
    l2Type: "int32_t",
    l3Type: "int32_t",
    mangled: "i32",
    l1l2: (l1, l2) -> '$l2 = lua_tointeger(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushinteger(_lua_state, $l2);',
  };
  static final MARSHAL_UINT64:LuaTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "int",
    l2Type: "uint64_t",
    l3Type: "uint64_t",
    mangled: "u64",
    l1l2: (l1, l2) -> 'lua_getfield(_lua_state, $l1, "high");
lua_getfield(_lua_state, $l1, "low");
$l2 = ((uint64_t)lua_tointeger(_lua_state, -2) << 32) | (uint32_t)lua_tointeger(_lua_state, -1);
lua_pop(_lua_state, 2);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_createtable(_lua_state, 0, 2);
lua_pushinteger(_lua_state, $l2 & 0xFFFFFFFF);
lua_setfield(_lua_state, -2, "low");
lua_pushinteger(_lua_state, ((uint64_t)$l2 >> 32) & 0xFFFFFFFF);
lua_setfield(_lua_state, -2, "high");',
  };
  static final MARSHAL_INT64:LuaTypeMarshal = {
    haxeType: (macro : haxe.Int64),
    l1Type: "int",
    l2Type: "int64_t",
    l3Type: "int64_t",
    mangled: "i64",
    l1l2: (l1, l2) -> 'lua_getfield(_lua_state, $l1, "high");
lua_getfield(_lua_state, $l1, "low");
$l2 = ((int64_t)lua_tointeger(_lua_state, -2) << 32) | (uint32_t)lua_tointeger(_lua_state, -1);
lua_pop(_lua_state, 2);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_createtable(_lua_state, 0, 2);
lua_pushinteger(_lua_state, (int32_t)($l2 & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "low");
lua_pushinteger(_lua_state, (int32_t)(((uint64_t)$l2 >> 32) & 0xFFFFFFFF));
lua_setfield(_lua_state, -2, "high");',
  };

  //static final MARSHAL_FLOAT32:LuaTypeMarshal = {};
  static final MARSHAL_FLOAT64:LuaTypeMarshal = {
    haxeType: (macro : Float),
    l1Type: "int",
    l2Type: "double",
    l3Type: "double",
    mangled: "f64",
    l1l2: (l1, l2) -> '$l2 = lua_tonumber(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushnumber(_lua_state, $l2);',
  };

  static final MARSHAL_STRING:LuaTypeMarshal = {
    haxeType: (macro : String),
    l1Type: "int",
    l2Type: "const char*",
    l3Type: "const char*",
    mangled: "s",
    l1l2: (l1, l2) -> '$l2 = lua_tostring(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushstring(_lua_state, $l2);',
  };

  static final MARSHAL_BYTES:LuaTypeMarshal = {
    haxeType: (macro : lua.UserData),
    l1Type: "int",
    l2Type: "uint8_t*",
    l3Type: "uint8_t*",
    mangled: "b",
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushlightuserdata(_lua_state, $l2);',
  };

  public function new(library:LuaLibrary) {
    super(library);
  }

  public function void():LuaTypeMarshal return MARSHAL_VOID;

  public function bool():LuaTypeMarshal return MARSHAL_BOOL;

  public function uint8():LuaTypeMarshal return MARSHAL_UINT8;
  public function int8():LuaTypeMarshal return MARSHAL_INT8;
  public function uint16():LuaTypeMarshal return MARSHAL_UINT16;
  public function int16():LuaTypeMarshal return MARSHAL_INT16;
  public function uint32():LuaTypeMarshal return MARSHAL_UINT32;
  public function int32():LuaTypeMarshal return MARSHAL_INT32;
  public function uint64():LuaTypeMarshal return MARSHAL_UINT64;
  public function int64():LuaTypeMarshal return MARSHAL_INT64;

  public function float32():LuaTypeMarshal throw "!";
  public function float64():LuaTypeMarshal return MARSHAL_FLOAT64;

  public function string():LuaTypeMarshal return MARSHAL_STRING;

  function bytesInternalType():LuaTypeMarshal return MARSHAL_BYTES;
  function bytesInternalOps(
    type:LuaTypeMarshal,
    alloc:(size:Expr)->Expr,
    blit:(source:Expr, srcpos:Expr, dest:Expr, dstpost:Expr, size:Expr)->Expr
  ):{
    toBytesCopy:(self:Expr, size:Expr)->Expr,
    fromBytesCopy:(bytes:Expr)->Expr,
    toBytesRef:Null<(self:Expr, size:Expr)->Expr>,
    fromBytesRef:Null<(bytes:Expr)->Expr>,
  } {
    // TODO: haxe.io.BytesData on Lua is Array<Int>, it really could be
    // the (native) String type, as it supports 0-bytes and need not be UTF-8
    return {
      toBytesCopy: (self, size) -> macro {
        var _self = ($self : lua.UserData);
        var _size = ($size : Int);
        var _data = ((untyped $e{library.fieldExpr("_ammer_native")}["_ammer_lua_tobytesdata"]) : (lua.UserData, Int) -> lua.Table<Int, Int>)(
          _self,
          _size
        );
        haxe.io.Bytes.ofData(lua.Table.toArray(_data)); // TODO: avoid this re-copy
      },
      fromBytesCopy: (bytes) -> macro {
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
      toBytesRef: null,
      fromBytesRef: null,
    };
  }

  function opaquePtrInternal(name:String):LuaTypeMarshal return {
    haxeType: (macro : lua.UserData),
    l1Type: "int",
    l2Type: '$name*',
    l3Type: '$name*',
    mangled: 'p${Mangle.identifier(name)}_',
    l1l2: (l1, l2) -> '$l2 = lua_touserdata(_lua_state, $l1);',
    l2ref: MARSHAL_NOOP1,
    l2l3: MARSHAL_CONVERT_DIRECT,
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_NOOP1,
    l2l1: (l2, l1) -> 'lua_pushlightuserdata(_lua_state, $l2);',
  };

  function haxePtrInternal(haxeType:ComplexType):LuaTypeMarshal return {
    haxeType: haxeType,
    l1Type: "int",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'h${Mangle.complexType(haxeType)}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };

  function closureInternal(
    ret:LuaTypeMarshal,
    args:Array<LuaTypeMarshal>
  ):LuaTypeMarshal return {
    haxeType: TFunction(
      args.map(arg -> arg.haxeType),
      ret.haxeType
    ),
    l1Type: "int",
    l2Type: '${library.config.internalPrefix}registry_node*',
    l3Type: "void*",
    mangled: 'c${ret.mangled}_${args.length}${args.map(arg -> arg.mangled).join("_")}_',
    l1l2: MARSHAL_REGISTRY_GET_NODE,
    l2ref: MARSHAL_REGISTRY_REF,
    l2l3: MARSHAL_CONVERT_DIRECT, // TODO: cast ...
    l3l2: MARSHAL_CONVERT_DIRECT,
    l2unref: MARSHAL_REGISTRY_UNREF,
    l2l1: MARSHAL_REGISTRY_GET_KEY,
  };
}

class Lua extends Base<
  LuaConfig,
  LuaLibraryConfig,
  LuaTypeMarshal,
  LuaLibrary,
  LuaMarshalSet
> {
  public function new(config:LuaConfig) {
    super("lua", config);
  }

  public function finalise():BuildProgram {
    return baseDynamicLinkProgram({
      includePaths: config.luaIncludePaths,
      libraryPaths: config.luaLibraryPaths,
      linkNames: ["lua"],
      libCode: lib -> lib.lb
        // TODO: just paste this instead of ail, i, d ...
        // TODO: name symbols with internalPrefix
        .ail("int _ammer_lua_tobytesdata(lua_State* _lua_state) {")
        .i()
          .ail("uint8_t* data = lua_touserdata(_lua_state, 1);")
          .ail("uint32_t size = lua_tointeger(_lua_state, 2);")
          .ail("lua_createtable(_lua_state, size, 0);")
          .ail("for (int i = 0; i < size; i++) {")
          .i()
            .ail("lua_pushinteger(_lua_state, i + 1);")
            .ail("lua_pushinteger(_lua_state, data[i]);")
            .ail("lua_settable(_lua_state, 3);")
          .d()
          .ail("}")
          .ail("return 1;")
        .d()
        .ail("}")
        .ail("int _ammer_lua_frombytesdata(lua_State* _lua_state) {")
        .i()
          // in the stack we get a table (+ size for now? can be determined maybe?)
          // we need to create a lightuserdata
          .ail("uint32_t size = lua_tointeger(_lua_state, 2);")
          .ail("uint8_t* data = (uint8_t*)malloc(size);") // TODO: mallocFunction, check NULL
          .ail("for (int i = 0; i < size; i++) {")
          .i()
            .ail("lua_pushinteger(_lua_state, i + 1);")
            .ail("lua_gettable(_lua_state, 1);")
            .ail("data[i] = lua_tointeger(_lua_state, 3);")
            .ail("lua_pop(_lua_state, 1);")
          .d()
          .ail("}")
          .ail("lua_pushlightuserdata(_lua_state, data);")
          .ail("return 1;")
        .d()
        .ail("}")
        .ail("int _ammer_init(lua_State* _lua_state) {")
        .i()
          .ail("luaL_Reg _init_wrap[] = {")
          .a(lib.lbInit.done())
          .ail('{"_ammer_lua_tobytesdata", _ammer_lua_tobytesdata},')
          .ail('{"_ammer_lua_frombytesdata", _ammer_lua_frombytesdata},')
          .ail("{NULL, NULL}")
          .ail("};")
          .ail("lua_newtable(_lua_state);")
          .ail("luaL_setfuncs(_lua_state, _init_wrap, 0);")
          .ail('lua_pushstring(_lua_state, _ammer_registry_name);')
          .ail("lua_newtable(_lua_state);")
          .ail("lua_settable(_lua_state, LUA_REGISTRYINDEX);")
          .ail('${lib.config.internalPrefix}registry.ctx = _lua_state;')
          .ail("return 1;")
        .d()
        .ail("}")
        .done(),
    });
  }
}

@:structInit
class LuaConfig extends BaseConfig {
  public var luaIncludePaths:Array<String> = null;
  public var luaLibraryPaths:Array<String> = null;
}

@:allow(ammer.core.plat.Lua)
class LuaLibrary extends BaseLibrary<
  LuaLibrary,
  LuaLibraryConfig,
  LuaTypeMarshal,
  LuaMarshalSet
> {
  var lbInit = new LineBuf();

  public function new(config:LuaLibraryConfig) {
    super(config, new LuaMarshalSet(this));
    // TODO: per OS ...
    var loadlib = 'assert(package.loadlib("lib${config.name}.dylib", "_ammer_init"))()';
    tdef.fields.push({
      pos: config.pos,
      name: "_ammer_native",
      kind: FVar(
        (macro : lua.Table<String, Dynamic>),
        macro untyped __lua__($v{loadlib})
      ),
      access: [APrivate, AStatic],
    });
    lb.ail("#include <lua.h>");
    lb.ail("#include <lualib.h>");
    lb.ail("#include <lauxlib.h>");
    lb.ail("#include <inttypes.h>");
    lb.ail("static size_t _ammer_ctr = 0;"); // TODO: internalPrefix
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
  }

  public function addFunction(
    ret:LuaTypeMarshal,
    args:Array<LuaTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr {
    if (pos == null) pos = config.pos;
    var name = mangleFunction(ret, args, code);
    lb
      .ail('static int ${name}(lua_State* _lua_state) {')
      .i()
        .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
        .lmapi(args, (idx, arg) -> arg.l1l2('${idx + 1}', '_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> arg.l2ref('_l2_arg_$idx'))
        .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
        .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
        .ifi(ret != LuaMarshalSet.MARSHAL_VOID)
          .ail('${ret.l3Type} ${config.returnIdent};')
          .ail(code)
          .ail('${ret.l2Type} _l2_return;')
          .ail(ret.l3l2(config.returnIdent, "_l2_return"))
          .ail(ret.l2l1("_l2_return", ""))
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail('return 1;')
        .ife()
          .ail(code)
          .lmapi(args, (idx, arg) -> arg.l2unref('_l2_arg_$idx'))
          .ail("return 0;")
        .ifd()
      .d()
      .al("}");
    lbInit.ail('{"${name}", ${name}},');
    var funcType = TFunction(args.map(arg -> arg.haxeType), ret.haxeType);
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
        .ail('${clType.type.l1Type} _l1_fn;')
        // first the function is pushed
        .ail(clType.type.l2l1("_l2_fn", ""))
        // then the arguments in direct order
        .lmapi(args, (idx, arg) -> clType.args[idx].l2l1('_l2_arg_$idx', ""))
        .ail('lua_call(_lua_state, ${args.length}, 1);')
        .ifi(clType.ret != LuaMarshalSet.MARSHAL_VOID)
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
        .ail('lua_State* _lua_state = ${config.internalPrefix}registry.ctx;')
        .ifi(ret != LuaMarshalSet.MARSHAL_VOID)
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

typedef LuaLibraryConfig = LibraryConfig;
typedef LuaTypeMarshal = BaseTypeMarshal;

#end
