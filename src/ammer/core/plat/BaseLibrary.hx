package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.LineBuf;
import ammer.core.utils.TypeUtils;

@:allow(ammer.core.plat)
abstract class BaseLibrary<
  TSelf:BaseLibrary<
    TSelf,
    TPlatform,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TMarshal
  >,
  TPlatform:Base<
    TPlatform,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TSelf,
    TMarshal
  >,
  TConfig:BaseConfig,
  TLibraryConfig:LibraryConfig,
  TTypeMarshal:BaseTypeMarshal,
  TMarshal:BaseMarshal<
    TMarshal,
    TPlatform,
    TConfig,
    TLibraryConfig,
    TSelf,
    TTypeMarshal
  >
> {
  public var marshal:TMarshal;
  public var outputPathRelative:String;

  var platform:TPlatform;
  var config:TLibraryConfig;
  var tdef:TypeDefinition;
  var tdefStaticCallbacks:TypeDefinition;
  var tdefs:Array<TypeDefinition> = [];
  var lb = new LineBuf();
  var functionNames:Map<String, Int> = new Map();
  var finalised = false;

  function new(platform:TPlatform, config:TLibraryConfig, marshal:TMarshal) {
    this.platform = platform;
    this.marshal = marshal;
    this.config = config;
    if (config.pos == null) config.pos = Context.currentPos();
    if (config.typeDefPack == null) config.typeDefPack = ["ammer", "externs"];
    if (config.typeDefName == null) config.typeDefName = 'CoreExtern_${config.name}';
    tdef = typeDefCreate();
    tdefs.push(tdefStaticCallbacks = {
      pos: config.pos,
      pack: config.typeDefPack,
      name: 'CoreExtern_${config.name}_StaticCallbacks',
      meta: [],
      kind: TDClass(null, [], false, true, false),
      fields: [],
    });
    // TODO: MSVC assumed to be LE (MSVC can also target BE: xbox)
    // TODO: the endian defines on the BSD variants are not tested
    // does not work on cpp: (!*(unsigned char*)(void*)&(uint16_t){1})
    lb.ail("#include <stdlib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#ifdef _WIN32
  #define LIB_EXPORT __declspec(dllexport)
#else
  #define LIB_EXPORT
#endif
#ifdef _MSC_VER
  #define _AMMER_BIG_ENDIAN 0
  #define bswap_16(x) _byteswap_ushort(x)
  #define bswap_32(x) _byteswap_ulong(x)
  #define bswap_64(x) _byteswap_uint64(x)
#elif defined(__APPLE__)
  #include <libkern/OSByteOrder.h>
  #if defined(__BIG_ENDIAN__)
    #define _AMMER_BIG_ENDIAN 1
  #else
    #define _AMMER_BIG_ENDIAN 0
  #endif
  #define bswap_16(x) OSSwapInt16(x)
  #define bswap_32(x) OSSwapInt32(x)
  #define bswap_64(x) OSSwapInt64(x)
#elif defined(__sun) || defined(sun)
  #include <sys/byteorder.h>
  #define _AMMER_BIG_ENDIAN (_BYTE_ORDER == _BIG_ENDIAN)
  #define bswap_16(x) BSWAP_16(x)
  #define bswap_32(x) BSWAP_32(x)
  #define bswap_64(x) BSWAP_64(x)
#elif defined(__FreeBSD__)
  #include <sys/endian.h>
  #define _AMMER_BIG_ENDIAN (_BYTE_ORDER == _BIG_ENDIAN)
  #define bswap_16(x) bswap16(x)
  #define bswap_32(x) bswap32(x)
  #define bswap_64(x) bswap64(x)
#elif defined(__OpenBSD__)
  #include <sys/types.h>
  #define _AMMER_BIG_ENDIAN (_BYTE_ORDER == _BIG_ENDIAN)
  #define bswap_16(x) swap16(x)
  #define bswap_32(x) swap32(x)
  #define bswap_64(x) swap64(x)
#elif defined(__NetBSD__)
  #include <sys/types.h>
  #include <machine/bswap.h>
  #define _AMMER_BIG_ENDIAN (_BYTE_ORDER == _BIG_ENDIAN)
  #if defined(__BSWAP_RENAME) && !defined(__bswap_32)
    #define bswap_16(x) bswap16(x)
    #define bswap_32(x) bswap32(x)
    #define bswap_64(x) bswap64(x)
  #endif
#else
  #include <byteswap.h>
  #define _AMMER_BIG_ENDIAN (__BYTE_ORDER == __BIG_ENDIAN)
#endif");
  }

  function finalise(platConfig:TConfig):Void {
    if (finalised) throw "library was already finalised";
    if (outputPathRelative == null) {
      outputPathRelative = '%LIB%${config.name}.%DLL%';
    }
    finalised = true;
    for (tdef in tdefs) {
      TypeUtils.defineType(tdef); // TODO: moduleDependency arg
    }
  }

  function mangleFunction(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    ?tag:String
  ):String {
    // The signature is also hashed because some FFI mechanisms (Neko in
    // particular) seem to not accept very long identifiers.
    var signature = '${ret.mangled}__${args.map(arg -> arg.mangled).join("__")}';
    var crcCode = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(code));
    var crcSignature = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(signature));
    var name = '${config.internalPrefix}_${tag != null ? '${tag}_' : ""}${StringTools.hex(crcCode, 8)}_'
      + '${config.name}_'
      + '${StringTools.hex(crcSignature, 8)}';
    if (functionNames.exists(name)) {
      // "num" prevents a conflict with Neko PRIM macros...
      return '${name}__num${functionNames[name]++}';
    } else {
      functionNames[name] = 0;
      return name;
    }
  }

  public function addInclude(include:SourceInclude):Void {
    lb.ail(include.toCode());
  }

  public function addCode(code:String):Void {
    lb.ail(code);
  }

  public function addHeaderCode(code:String):Void {
    // noop for most platforms
  }

  public function addFunction(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    ?options:FunctionOptions
  ):Expr {
    lb.ail('// args: [${args.map(a -> a.mangled).join(", ")}]');
    lb.ail('// ret:  ${ret.mangled}');
    if (options == null) options = {};
    if (options.pos == null) options.pos = config.pos;
    if (options.l3Return == null) options.l3Return = config.returnIdent;
    var name = mangleFunction(ret, args, code);
    return addNamedFunction(name, ret, args, code, options);
  }

  function baseAddNamedFunction(
    args:Array<TTypeMarshal>,
    argsL1:Array<String>,
    ret:TTypeMarshal,
    retL1Name:String,
    code:String,
    lb:LineBuf,
    options:FunctionOptions
  ):Void {
    lb
      .ifi(options.comment != null)
        .ail("// comment: " + options.comment)
      .ifd()
      .lmapi(args, (idx, arg) -> '${arg.l2Type} _l2_arg_${idx};')
      .lmapi(args, (idx, arg) -> arg.l1l2(argsL1[idx], '_l2_arg_$idx'))
      .lmapi(args, (idx, arg) -> '${arg.l3Type} ${config.argPrefix}${idx};')
      .lmapi(args, (idx, arg) -> arg.l2l3('_l2_arg_$idx', '${config.argPrefix}${idx}'))
      .ifi(ret.mangled != "v" && config.returnIdent == options.l3Return)
        .ail('${ret.l3Type} ${config.returnIdent};')
      .ifd()
      .ail(code)
      .ifi(ret.mangled != "v")
        .ail('${ret.l2Type} _l2_return;')
        .ail(ret.l3l2(options.l3Return, "_l2_return"))
        .ifi(retL1Name != "") // TODO: not great, only needed for Lua
          .ail('${ret.l1Type} ${retL1Name};')
        .ifd()
        .ail(ret.l2l1("_l2_return", retL1Name))
      .ifd();
  }
  abstract public function addNamedFunction(
    name:String,
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    options:FunctionOptions
  ):Expr;

  abstract public function closureCall(
    fn:String,
    clType:MarshalClosure<TTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String;

  function baseStaticCall(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:Expr
  ):String {
    var name = mangleFunction(ret, args, "", "scb");
    tdefStaticCallbacks.fields.push({
      pos: config.pos,
      meta: [{
        pos: config.pos,
        name: ":keep",
      }],
      name: name,
      kind: FFun({
        ret: ret.haxeType,
        expr: code,
        args: args.mapi((idx, arg) -> ({
          name: 'arg$idx',
          type: arg.haxeType,
        }:FunctionArg)),
      }),
      access: [APublic, AStatic],
    });
    return name;
  }
  abstract public function staticCall(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String;

  abstract public function addCallback(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String
  ):String;

  public function addStaticCallback(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:Expr
  ):String {
    return addCallback(
      ret,
      args,
      staticCall(
        ret,
        args,
        code,
        "_return",
        args.mapi((idx, arg) -> '_arg$idx')
      )
    );
  }

  function typeDefCreate(addToDefs:Bool = true):TypeDefinition {
    var ret = {
      pos: config.pos,
      pack: config.typeDefPack,
      name: config.typeDefName,
      meta: [],
      kind: TDClass(
        null,
        [],
        false,
        true,
        false
      ),
      isExtern: false,
      fields: [],
    };
    if (addToDefs) {
      tdefs.push(ret);
    }
    return ret;
  }

  public function typeDefExpr():Expr {
    return macro $p{config.typeDefPack.concat([config.typeDefName])};
  }

  public function fieldExpr(field:String):Expr {
    return macro $p{config.typeDefPack.concat([config.typeDefName, field])};
  }
}

#end
