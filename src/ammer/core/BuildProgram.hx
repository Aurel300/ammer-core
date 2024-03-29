package ammer.core;

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.BuildOp.BuildOpResult;
import ammer.core.BuildOp.BuildOpDependency;
import ammer.core.BuildOp.BuildOpCommand;

using StringTools;

class BuildProgram {
  // TODO: configurable MSVC and system
  public static var useMSVC = Sys.systemName() == "Windows";
  public static var extensionDll = (switch (Sys.systemName()) {
    case "Windows": "dll";
    case "Mac": "dylib";
    case _: "so";
  });

  public var ops:Array<BuildOp>;

  public static function extensions(path:String):String {
    return path
      .replace("%OBJ%", useMSVC ? "obj" : "o")
      .replace("%LIB%", useMSVC ? "" : "lib")
      .replace("%DLL%", extensionDll);
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

  function processLinkOptions(
    opt:ammer.core.BuildOp.MakeLinkOptions
  ):Array<String> {
    var args = [];
    if (useMSVC) {
      for (d in opt.defines) {
        args.push('/D$d');
      }
      args.push("/link");
      for (path in opt.libraryPaths)
        args.push('/LIBPATH:"$path"');
      for (lib in opt.libraries.concat(opt.staticLibraries != null ? opt.staticLibraries : [])) // TODO: static/dynamic linking on Windows
        args.push('$lib.lib');
    } else {
      for (d in opt.defines) {
        args.push("-D");
        args.push(d);
      }
      for (path in opt.libraryPaths)
        args.push('-L$path');
      if (opt.frameworks != null) {
        // TODO: emit warning or error when not used on Mac
        for (framework in opt.frameworks) {
          args.push("-framework");
          args.push(framework);
        }
      }
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
    }
    return args;
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
      case [File(dst), File(src), CompileObject(lang, opt)]:
        if (useMSVC) {
          var args = [];
          for (d in opt.defines) {
            args.push('/D$d');
          }
          for (path in opt.includePaths) {
            args.push("/I");
            args.push(path);
          }
          args = args.concat(['/Fo${extensions(dst)}', "/c", extensions(src)]);
          run("cl.exe", args);
        } else {
          var args = ["-fPIC", "-o", extensions(dst), "-c", extensions(src)];
          if (lang == Cpp || lang == ObjectiveCpp) {
            args.push("-std=c++11");
          }
          for (d in opt.defines) {
            args.push("-D");
            args.push(d);
          }
          for (path in opt.includePaths) {
            args.push("-I");
            args.push(path);
          }
          run(lang.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
        }
      case [_, _, CompileObject(_)]: throw "invalid CompileObject command";
      case [File(dst), File(src), LinkLibrary(lang, opt)]:
        if (useMSVC) {
          var args = ['/Fe${extensions(dst)}', "/LD", extensions(src)]
            .concat(processLinkOptions(opt));
          run("cl.exe", args);
        } else {
          var args = ["-m64", "-o", extensions(dst)];
          if (Sys.systemName() == "Mac") {
            // TODO: make install_name configurable (e.g. @rpath/../etc)
            args.push("-install_name");
            args.push('@executable_path/${extensions(opt.linkName)}');
            args.push("-dynamiclib");
          } else {
            args.push("-shared");
            args.push("-fPIC");
          }
          args.push(extensions(src));
          args = args.concat(processLinkOptions(opt));
          run(lang.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
        }
      case [_, _, LinkLibrary(_)]: throw "invalid LinkLibrary command";
      case [File(dst), File(src), LinkExecutable(lang, opt)]:
        if (useMSVC) {
          var args = ['/Fe${extensions(dst)}', extensions(src)]
            .concat(processLinkOptions(opt));
          run("cl.exe", args);
        } else {
          var args = ["-m64", "-o", extensions(dst), extensions(src)]
            .concat(processLinkOptions(opt));
          run(lang.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
        }
      case [_, _, LinkExecutable(_)]: throw "invalid LinkExecutable command";
      case [File(path), _, EnsureDirectory]:
        Sys.println('mkdir $path');
        sys.FileSystem.createDirectory(extensions(path));
      case [_, _, Command(cmd, args, process)]:
        if (process != null) {
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
