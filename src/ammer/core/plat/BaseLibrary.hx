package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.LineBuf;

@:allow(ammer.core.plat)
abstract class BaseLibrary<
  TSelf:BaseLibrary<
    TSelf,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TMarshal
  >,
  TConfig:BaseConfig,
  TLibraryConfig:LibraryConfig,
  TTypeMarshal:BaseTypeMarshal,
  TMarshal:BaseMarshal<
    TMarshal,
    TConfig,
    TLibraryConfig,
    TSelf,
    TTypeMarshal
  >
> {
  public var marshal:TMarshal;

  var config:TLibraryConfig;
  var tdef:TypeDefinition;
  var tdefs:Array<TypeDefinition> = [];
  var lb = new LineBuf();
  var functionNames:Map<String, Int> = new Map();
  var finalised = false;

  function new(config:TLibraryConfig, marshal:TMarshal) {
    this.marshal = marshal;
    this.config = config;
    if (config.pos == null) config.pos = Context.currentPos();
    if (config.typeDefPack == null) config.typeDefPack = ["ammer", "externs"];
    if (config.typeDefName == null) config.typeDefName = 'CoreExtern_${config.name}';
    tdef = typeDefCreate();
    lb.ail("#include <stdlib.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#ifdef _WIN32
  #define LIB_EXPORT __declspec(dllexport)
#else
  #define LIB_EXPORT
#endif
");
  }

  function finalise(config:TConfig):Void {
    if (finalised) throw "library was already finalised";
    finalised = true;
    for (tdef in tdefs) {
      Context.defineType(tdef); // TODO: moduleDependency arg
    }
  }

  function mangleFunction(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    ?tag:String
  ):String {
    var crc = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(code));
    var name = '${config.internalPrefix}_${tag != null ? '${tag}_' : ""}${StringTools.hex(crc, 8)}_'
      + '${ret.mangled}__${args.map(arg -> arg.mangled).join("__")}';
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

  abstract public function addCallback(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String
  ):String;

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
