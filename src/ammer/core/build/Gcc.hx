package ammer.core.build;

#if macro

using StringTools;

@:structInit
class GccConfig extends BaseBuilderConfig {}

class Gcc extends BaseBuilder<GccConfig> {
  public function new(config:GccConfig) {
    super("gcc", config);
  }

  function extensions(path:String):String {
    return path
      .replace("%OBJ%", "o")
      .replace("%LIB%", "lib")
      .replace("%DLL%", extensionDll);
  }

  function processLinkOptions(opt:ammer.core.build.BuildOp.MakeLinkOptions):Array<String> {
    var args = [];
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
    if (opt.staticLibraries != null && opt.staticLibraries.length > 0) {
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
    return args;
  }

  function buildCompileObject(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeCompileOptions
  ):Void {
    var args = ["-fPIC", "-o", dst, "-c", src];
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

  function buildLinkLibrary(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void {
    var args = ["-m64", "-o", dst];
    if (Sys.systemName() == "Mac") {
      // TODO: make install_name configurable (e.g. @rpath/../etc)
      args.push("-install_name");
      args.push('@executable_path/${extensions(opt.linkName)}');
      args.push("-dynamiclib");
    } else {
      args.push("-shared");
      args.push("-fPIC");
    }
    args.push(src);
    args = args.concat(processLinkOptions(opt));
    run(lang.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
  }

  function buildLinkExecutable(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void {
    var args = ["-m64", "-o", dst, src]
      .concat(processLinkOptions(opt));
    run(lang.match(Cpp | ObjectiveCpp) ? "g++" : "cc", args);
  }
}

#end
