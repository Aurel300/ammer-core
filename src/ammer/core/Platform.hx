package ammer.core;

#if macro

import haxe.macro.Context;

class Platform {
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

  public var kind(default, null):PlatformId;
  var plat:Dynamic;

  function new(kind:PlatformId, plat:Dynamic) {
    this.kind = kind;
    this.plat = plat;
  }

  public function createLibrary(config:LibraryConfig):Library {
    return @:privateAccess new Library(kind, plat.createLibrary(config));
  }

  public function addLibrary(library:Library):Void {
    plat.addLibrary(@:privateAccess library.library);
  }

  public function finalise():BuildProgram {
    return plat.finalise();
  }
}

#end
