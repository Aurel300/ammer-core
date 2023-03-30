package ammer.core;

#if macro

import haxe.macro.Context;
import ammer.core.build.BuildProgram;

/**
A wrapper for `ammer.core.build.*` types, representing a build system.

See https://aurel300.github.io/ammer/core-api.html#builder
**/
class Builder {
  /**
  Creates a `Builder` corresponding to the current operating system: MSVC on
  Windows, GCC otherwise.

  Note: if this naive selection is not correct, construct a builder directly,
  for example with `new ammer.core.build.Gcc(config)`.
  **/
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

  /**
  Which builder is this?
  **/
  public var kind(default, null):BuilderId;

  /**
  The underlying `ammer.core.build.*` type.
  **/
  var builder:Dynamic;

  function new(kind:BuilderId, builder:Dynamic) {
    this.kind = kind;
    this.builder = builder;
  }

  /**
  Builds the given program (obtained from finalising a `Platform`). This may
  create files, directories, invoke the C compiler/linker, etc.
  **/
  public function build(program:BuildProgram):Void {
    builder.build(program);
  }
}

#end
