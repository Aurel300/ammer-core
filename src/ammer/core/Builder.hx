package ammer.core;

#if macro

import haxe.macro.Context;
import ammer.core.build.BuildProgram;

class Builder {
  public static function createCurrentBuilder(config:ammer.core.build.BaseBuilderConfig):Builder {
    var kind:BuilderId;
    var builder:Dynamic;
    if (Sys.systemName() == "Windows") {
      kind = BuilderId.Msvc;
      builder = new ammer.core.build.Msvc((cast config : ammer.core.build.Msvc.MsvcConfig));
    } else {
      kind = BuilderId.Gcc;
      builder = new ammer.core.build.Gcc((cast config : ammer.core.build.Gcc.GccConfig));
    }
    return new Builder(kind, builder);
  }

  public var kind(default, null):BuilderId;
  var builder:Dynamic;

  function new(kind:BuilderId, builder:Dynamic) {
    this.kind = kind;
    this.builder = builder;
  }

  public function build(program:BuildProgram):Void {
    builder.build(program);
  }
}

#end
