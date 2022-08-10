package ammer.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.BuildOp.BuildOpResult;
import ammer.core.BuildOp.BuildOpDependency;
import ammer.core.BuildOp.BuildOpCommand;

using StringTools;

class BuildProgram {
  // TODO: configurable MSVC and system
  static var useMSVC = Sys.systemName() == "Windows";

  public var ops:Array<BuildOp>;

  static function extensions(path:String):String {
    return path
      //.replace("%OBJ%", Ammer.config.useMSVC ? "obj" : "o")
      .replace("%OBJ%", "o")
      .replace("%DLL%", switch (Sys.systemName()) {
        case "Windows": "dll";
        case "Mac": "dylib";
        case _: "so";
      });
  }

  static function run(cmd:String, args:Array<String>):Bool {
    // TODO: require success or throw
    Sys.println('run $cmd $args');
    return Sys.command(cmd, args) == 0;
  }

  public function new(ops:Array<BuildOp>) {
    this.ops = ops;
  }

  public function build():Void {
    buildSub(ops);
  }

  function buildSub(ops:Array<BuildOp>):Void {
    for (op in ops) switch (op) {
      case BOCwd(path, sub):
        var path = extensions(path);
        var oldCwd = Sys.getCwd();
        Sys.setCwd(path);
        Sys.println('pushd $path');
        buildSub(sub);
        Sys.setCwd(oldCwd);
        Sys.println('popd $oldCwd');
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
    // TODO: check (or build) dependencies
    return true;
  }

  // TODO: log commands after expansion
  function buildCommand(
    result:BuildOpResult,
    requires:BuildOpDependency,
    command:BuildOpCommand
  ):Void {
    switch [result, requires, command] {
      case [_, _, Phony]:
      case [File(dst), File(src), Copy]:
        Sys.println('copy $src -> $dst');
        sys.io.File.copy(extensions(src), extensions(dst));
      case [_, _, Copy]: throw "invalid Copy command";
      case [File(dst), _, WriteContent(data)]:
        Sys.println('write $dst');
        sys.io.File.saveContent(extensions(dst), data);
      case [File(dst), _, WriteData(data)]:
        Sys.println('write $dst');
        sys.io.File.saveBytes(extensions(dst), data);
      case [File(dst), File(src), CompileObject(abi, opt)]:
        if (useMSVC) {
          var args = ['/Fe:${extensions(dst)}', "/c", extensions(src)];
          for (path in opt.includePaths) {
            args.push("/I");
            args.push('"$path"');
          }
          run("cl.exe", args);
        } else {
          var args = ["-fPIC", "-o", extensions(dst), "-c", extensions(src)];
          if (abi == Cpp || abi == ObjectiveCpp) {
            args.push("-std=c++11");
          }
          for (path in opt.includePaths) {
            args.push("-I");
            args.push(path);
          }
          run(abi.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
        }
      case [_, _, CompileObject(_)]: throw "invalid CompileObject command";
      case [File(dst), File(src), LinkLibrary(abi, opt)]:
        if (useMSVC) {
          var args = ['/Fe:${extensions(dst)}', "/LD", extensions(src)];
          for (d in opt.defines) {
            args.push('/D$d');
          }
          args.push("/link");
          for (path in opt.libraryPaths)
            args.push('/LIBPATH:"$path"');
          for (lib in opt.libraries.concat(opt.staticLibraries != null ? opt.staticLibraries : [])) // TODO: static/dynamic linking on Windows
            args.push('$lib.lib');
          run("cl.exe", args);
        } else {
          var args = ["-m64", "-o", extensions(dst)];
          if (Sys.systemName() == "Mac") {
            args.push("-dynamiclib");
          } else {
            args.push("-shared");
            args.push("-fPIC");
          }
          args.push(extensions(src));
          for (d in opt.defines) {
            args.push("-D");
            args.push(d);
          }
          for (path in opt.libraryPaths)
            args.push('-L$path');
          if (opt.staticLibraries != null) {
            if (Sys.systemName() == "Mac") {
              // TODO: mixing dynamic and static linking on Mac
              // https://stackoverflow.com/questions/4576235/mixed-static-and-dynamic-link-on-mac-os
              for (lib in opt.staticLibraries)
                args.push('-l$lib');
            } else {
              args.push("-Wl,-Bstatic");
              for (lib in opt.staticLibraries)
                args.push('-l$lib');
              args.push("-Wl,-Bdynamic");
            }
          }
          for (lib in opt.libraries)
            args.push('-l$lib');
          run(abi.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
        }
      case [_, _, LinkLibrary(_)]: throw "invalid LinkLibrary command";
      case [File(path), _, EnsureDirectory]:
        Sys.println('mkdir $path');
        sys.FileSystem.createDirectory(extensions(path));
      case [_, _, Command(cmd, args)]:
        run(cmd, args);
    }
  }
}
