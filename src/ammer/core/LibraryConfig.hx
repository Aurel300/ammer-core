package ammer.core;

#if macro

import haxe.macro.Expr;

@:structInit
class LibraryConfig {
  public var name:String;
  public var linkNames:Array<String> = [];
  public var includePaths:Array<String> = [];
  public var libraryPaths:Array<String> = [];
  public var abi:LibraryAbi = C;
  public var pos:Position = null;
  public var typeDefPack:Array<String> = null;
  public var typeDefName:String = null;
  public var mallocFunction:String = "malloc";
  public var callocFunction:String = "calloc";
  public var freeFunction:String = "free";
  public var memcpyFunction:String = "memcpy";
  public var internalPrefix:String = "_ammer_core_";

  // these two could be per-function?
  public var argPrefix:String = "_arg";
  public var returnIdent:String = "_return";
}

@:using(ammer.core.LibraryConfig.LibraryAbiTools)
enum LibraryAbi {
  C;
  Cpp;
  ObjectiveC;
  ObjectiveCpp;
}

class LibraryAbiTools {
  public static function extension(abi:LibraryAbi):String {
    return (switch (abi) {
      case C: "c";
      case Cpp: "cpp";
      case ObjectiveC: "m";
      case ObjectiveCpp: "mm";
    });
  }

  public static function extensionHeader(abi:LibraryAbi):String {
    return (switch (abi) {
      case C: "h";
      case Cpp: "hpp";
      case ObjectiveC: "h";
      case ObjectiveCpp: "hpp"; // TODO: is this correct?
    });
  }
}

#end
