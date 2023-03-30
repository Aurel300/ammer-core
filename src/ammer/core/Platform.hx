package ammer.core;

#if macro

import haxe.macro.Context;
import ammer.core.build.BuildProgram;

/**
A wrapper for `ammer.core.plat.*` types. This hides the relatively complex type
parameter scheme used by `ammer.core.plat.Base`, although some type casts are
needed to pass a platform config or library config.

See https://aurel300.github.io/ammer/core-api.html#platform
**/
class Platform {
  /**
  Creates a `Platform` instance corresponding to the current Haxe target (e.g.
  if `-hl example.hl` is passed to Haxe, the HashLink platform will be used).
  If no output is specified (`--no-output`), then the dummy `None` platform is
  returned.
  **/
  public static function createCurrentPlatform(config:ammer.core.plat.BaseConfig):Platform {
    var kind:PlatformId;
    var plat:Dynamic;
    switch (Context.definedValue("target.name")) {
      case "cpp":
        kind = PlatformId.Cpp;
        plat = new ammer.core.plat.Cpp((cast config : ammer.core.plat.Cpp.CppConfig));
      case "cs":
        kind = PlatformId.Cs;
        plat = new ammer.core.plat.Cs((cast config : ammer.core.plat.Cs.CsConfig));
      case "eval":
        kind = PlatformId.Eval;
        plat = new ammer.core.plat.Eval((cast config : ammer.core.plat.Eval.EvalConfig));
      case "hl":
        kind = PlatformId.Hashlink;
        plat = new ammer.core.plat.Hashlink((cast config : ammer.core.plat.Hashlink.HashlinkConfig));
      case "java":
        kind = PlatformId.Java;
        plat = new ammer.core.plat.Java((cast config : ammer.core.plat.Java.JavaConfig));
      case "lua":
        kind = PlatformId.Lua;
        plat = new ammer.core.plat.Lua((cast config : ammer.core.plat.Lua.LuaConfig));
      case "neko":
        kind = PlatformId.Neko;
        plat = new ammer.core.plat.Neko((cast config : ammer.core.plat.Neko.NekoConfig));
      case "js":
        kind = PlatformId.Nodejs;
        plat = new ammer.core.plat.Nodejs((cast config : ammer.core.plat.Nodejs.NodejsConfig));
      case "python":
        kind = PlatformId.Python;
        plat = new ammer.core.plat.Python((cast config : ammer.core.plat.Python.PythonConfig));

      case _:
        kind = PlatformId.None;
        plat = new ammer.core.plat.None((cast config : ammer.core.plat.None.NoneConfig));
    };
    return new Platform(kind, plat);
  }

  /**
  Which platform is this?
  **/
  public var kind(default, null):PlatformId;

  /**
  The underlying `ammer.core.plat.*` type.
  **/
  var plat:Dynamic;

  function new(kind:PlatformId, plat:Dynamic) {
    this.kind = kind;
    this.plat = plat;
  }

  /**
  Creates a library for this platform given a library configuration, then
  returns it.
  **/
  public function createLibrary(config:LibraryConfig):Library {
    return @:privateAccess new Library(kind, plat.createLibrary(config));
  }

  /**
  Adds a completed library to this platform. Once added, the library cannot be
  modified anymore. The library will be included in the build program returned
  by `finalise`.
  **/
  public function addLibrary(library:Library):Void {
    plat.addLibrary(@:privateAccess library.library);
  }

  /**
  Finalises this platform. Libraries cannot be created or added after this is
  called. Returns a build program (sequence of build steps) that can be passed
  to a `Builder`.
  **/
  public function finalise():BuildProgram {
    return plat.finalise();
  }
}

#end
