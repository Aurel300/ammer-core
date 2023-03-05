package ammer.core.build;

#if macro

using StringTools;

@:structInit
class MsvcConfig extends BaseBuilderConfig {}

class Msvc extends BaseBuilder<MsvcConfig> {
  public function new(config:MsvcConfig) {
    super("msvc", config);
  }

  function extensions(path:String):String {
    return path
      .replace("%OBJ%", "obj")
      .replace("%LIB%", "")
      .replace("%DLL%", extensionDll);
  }

  function processLinkOptions(opt:ammer.core.build.BuildOp.MakeLinkOptions):Array<String> {
    var args = [];
    for (d in opt.defines) {
      args.push('/D$d');
    }
    args.push("/link");
    for (path in opt.libraryPaths)
      args.push('/LIBPATH:"$path"');
    for (lib in opt.libraries.concat(opt.staticLibraries != null ? opt.staticLibraries : [])) // TODO: static/dynamic linking on Windows
      args.push('$lib.lib');
    return args;
  }

  function buildCompileObject(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeCompileOptions
  ):Void {
    var args = [];
    for (d in opt.defines) {
      args.push('/D$d');
    }
    for (path in opt.includePaths) {
      args.push("/I");
      args.push(path);
    }
    args = args.concat(['/Fo$dst', "/c", src]);
    run("cl.exe", args);
  }

  function buildLinkLibrary(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void {
    var args = ['/Fe$dst', "/LD", src]
      .concat(processLinkOptions(opt));
    run("cl.exe", args);
  }

  function buildLinkExecutable(
    src:String, dst:String, lang:LibraryLanguage, opt:ammer.core.build.BuildOp.MakeLinkOptions
  ):Void {
    var args = ['/Fe$dst', src]
      .concat(processLinkOptions(opt));
    run("cl.exe", args);
  }
}

#end
