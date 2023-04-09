package ammer.core;

#if macro

import haxe.macro.Expr;

@:structInit
class LibraryConfig {
  /**
  The name of the library. Should only consist of alphanumerics and underscores,
  because this identifier will be used in filenames and type names.
  **/
  public var name:String;

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.linknames
  **/
  public var linkNames:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.includepaths
  **/
  public var includePaths:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.librarypaths
  **/
  public var libraryPaths:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.frameworks
  **/
  public var frameworks:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.defines
  **/
  public var defines:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.definescodeonly
  **/
  public var definesCodeOnly:Array<String> = [];

  /**
  See https://aurel300.github.io/ammer/ref-flags.html#lib.language
  **/
  public var language:LibraryLanguage = C;

  /**
  Haxe code position to use for generated expressions.
  **/
  public var pos:Position = null;

  /**
  Package to use for generated types.
  Default: `ammer.externs`
  **/
  public var typeDefPack:Array<String> = null;

  /**
  Name to use for the generated library type.
  Default: `CoreExtern_(name)`
  **/
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
