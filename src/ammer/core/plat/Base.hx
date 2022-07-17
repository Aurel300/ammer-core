package ammer.core.plat;

import haxe.macro.Expr;

abstract class Base<
  TConfig:BaseConfig,
  TLibraryConfig:LibraryConfig,
  TTypeMarshal:BaseTypeMarshal,
  TLibrary:BaseLibrary<
    TLibrary,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TMarshalSet
  >,
  TMarshalSet:BaseMarshalSet<
    TMarshalSet,
    TConfig,
    TLibraryConfig,
    TLibrary,
    TTypeMarshal
  >
> {
  public final platformId:String;
  var config:TConfig;
  var libraries:Array<TLibrary> = [];

  function new(platformId:String, config:TConfig) {
    this.platformId = platformId;
    this.config = config;
  }

  public function addLibrary(library:TLibrary):Void {
    @:privateAccess library.finalise(config);
    libraries.push(library);
  }

  abstract public function finalise():BuildProgram;

  function baseDynamicLinkProgram(options:{
    ?includePaths:Array<String>,
    ?libraryPaths:Array<String>,
    ?defines:Array<String>,
    ?linkNames:Array<String>,
    ?outputPath:TLibrary->String,
  }):BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.abi.extension();
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));
      ops.push(BOAlways(
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.$ext'),
        WriteContent(lib.lb.done())
      ));
      ops.push(BODependent(
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%OBJ%'),
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.$ext'),
        CompileObject(lib.config.abi, {
          includePaths: (options.includePaths != null ? options.includePaths : [])
            .concat(lib.config.includePaths),
        })
      ));
      ops.push(BODependent(
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%DLL%'),
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%OBJ%'),
        LinkLibrary(lib.config.abi, {
          defines: (options.defines != null ? options.defines : []),
          libraryPaths: (options.libraryPaths != null ? options.libraryPaths : [])
            .concat(lib.config.libraryPaths),
          libraries: (options.linkNames != null ? options.linkNames : [])
            .concat(lib.config.linkNames),
          staticLibraries: [],
        })
      ));
      ops.push(BODependent(
        File(options.outputPath != null
          ? options.outputPath(lib)
          : '${config.outputPath}/lib${lib.config.name}.%DLL%'),
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%DLL%'),
        Copy
      ));
    }
    return new BuildProgram(ops);
  }
}
