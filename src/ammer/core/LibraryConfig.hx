package ammer.core;

#if macro

import haxe.macro.Expr;

@:structInit
class LibraryConfig {
  public var name:String;
  public var linkNames:Array<String> = [];
  public var includePaths:Array<String> = [];
  public var libraryPaths:Array<String> = [];
  public var language:LibraryLanguage = C;
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

#end
