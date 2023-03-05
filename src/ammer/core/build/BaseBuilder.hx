package ammer.core.build;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.build.BuildOp.BuildOpResult;
import ammer.core.build.BuildOp.BuildOpDependency;
import ammer.core.build.BuildOp.BuildOpCommand;

using StringTools;

abstract class BaseBuilder<
  TConfig:BaseBuilderConfig
> {
  public final builderId:String;
  var config:TConfig;

  function new(builderId:String, config:TConfig) {
    this.builderId = builderId;
    this.config = config;
  }

  public function build(program:BuildProgram):Void {
    buildSub(program.ops);
  }

  function buildSub(ops:Array<BuildOp>):Void {
    for (op in ops) switch (op) {
      case BOCwd(extensions(_) => path, sub):
        withCwd(path, () -> buildSub(sub));
      case BOAlways(result, var command):
        buildCommand(result, None, command);
      case BODependent(result, requires, var command):
        if (checkDependency(result, requires))
          buildCommand(result, requires, command);
    }
  }

  function checkDependency(
    result:BuildOpResult,
    requires:BuildOpDependency
  ):Bool {
    // TODO: actually check dependencies
    return true;
  }

  var extensionDll = (switch (Sys.systemName()) {
    case "Windows": "dll";
    case "Mac": "dylib";
    case _: "so";
  });
  abstract function extensions(path:String):String;

  function run(cmd:String, args:Array<String>):Bool {
    // TODO: require success or throw
    Sys.println('run $cmd $args');
    return Sys.command(cmd, args) == 0;
  }

  function withCwd(path:String, f:()->Void):Void {
    var oldCwd = Sys.getCwd();
    Sys.setCwd(path);
    Sys.println('pushd $path');
    f();
    Sys.setCwd(oldCwd);
    Sys.println('popd $oldCwd');
  }

  function withEnv(key:String, val:String, f:()->Void):Void {
    var oldVal = Sys.getEnv(key);
    Sys.putEnv(key, val);
    Sys.println('set env $key = $val');
    f();
    Sys.putEnv(key, oldVal);
  }

  abstract function processLinkOptions(opt:ammer.core.build.BuildOp.MakeLinkOptions):Array<String>;
  abstract function buildCompileObject(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeCompileOptions
  ):Void;
  abstract function buildLinkLibrary(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void;
  abstract function buildLinkExecutable(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void;

  function buildCommand(
    result:BuildOpResult,
    requires:BuildOpDependency,
    command:BuildOpCommand
  ):Void {
    switch [result, requires, command] {
      case [_, _, Phony]:
      case [File(extensions(_) => dst), File(extensions(_) => src), Copy]:
        Sys.println('copy $src -> $dst');
        sys.io.File.copy(src, dst);
      case [_, _, Copy]: throw "invalid Copy command";
      case [File(extensions(_) => dst), _, WriteContent(data)]:
        Sys.println('write $dst (${data.length} characters)');
        sys.io.File.saveContent(dst, data);
      case [File(extensions(_) => dst), _, WriteData(data)]:
        Sys.println('write $dst (${data.length} bytes)');
        sys.io.File.saveBytes(dst, data);
      case [File(extensions(_) => dst), File(extensions(_) => src), CompileObject(lang, opt)]:
        Sys.println('compile object $src -> $dst');
        buildCompileObject(src, dst, lang, opt);
      case [_, _, CompileObject(_)]: throw "invalid CompileObject command";
      case [File(extensions(_) => dst), File(extensions(_) => src), LinkLibrary(lang, opt)]:
        Sys.println('link library $src -> $dst');
        buildLinkLibrary(src, dst, lang, opt);
      case [_, _, LinkLibrary(_)]: throw "invalid LinkLibrary command";
      case [File(extensions(_) => dst), File(extensions(_) => src), LinkExecutable(lang, opt)]:
        Sys.println('link executable $src -> $dst');
        buildLinkExecutable(src, dst, lang, opt);
      case [_, _, LinkExecutable(_)]: throw "invalid LinkExecutable command";
      case [File(extensions(_) => path), _, EnsureDirectory]:
        Sys.println('mkdir $path');
        sys.FileSystem.createDirectory(path);
      case [_, _, Command(cmd, args, process)]:
        if (process != null) {
          Sys.println('run $cmd $args');
          var proc = new sys.io.Process(cmd, args);
          var code = proc.exitCode();
          process(code, proc);
          proc.close();
        } else {
          run(cmd, args);
        }
    }
  }
}

#end
