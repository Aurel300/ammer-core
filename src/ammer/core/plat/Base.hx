package ammer.core.plat;

import haxe.macro.Expr;

@:allow(ammer.core.plat)
abstract class Base<
  TSelf:Base<
    TSelf,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TLibrary,
    TMarshal
  >,
  TConfig:BaseConfig,
  TLibraryConfig:LibraryConfig,
  TTypeMarshal:BaseTypeMarshal,
  TLibrary:BaseLibrary<
    TLibrary,
    TSelf,
    TConfig,
    TLibraryConfig,
    TTypeMarshal,
    TMarshal
  >,
  TMarshal:BaseMarshal<
    TMarshal,
    TSelf,
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

  abstract public function createLibrary(libConfig:TLibraryConfig):TLibrary;

  public function addLibrary(library:TLibrary):Void {
    @:privateAccess library.finalise(config);
    libraries.push(library);
  }

  abstract public function finalise():BuildProgram;

  function baseDynamicLinkProgram(options:{
    ?includePaths:Array<String>,
    ?libraryPaths:Array<String>,
    ?linkNames:Array<String>,
    ?defines:Array<String>,
  }):BuildProgram {
    var ops:Array<BuildOp> = [];
    for (lib in libraries) {
      var ext = lib.config.language.extension();
      ops.push(BOAlways(File('${config.buildPath}/${lib.config.name}'), EnsureDirectory));
      ops.push(BOAlways(File(config.outputPath), EnsureDirectory));

      // Disabling the following operation is useful for debugging. When
      // disabled, the generated C source is no longer rewritten when Haxe is
      // invoked, but the remaining operations (compiling objects and linking
      // a dynamic library) are still performed. It is thus possible to change
      // the generated C source, e.g. to insert debugging statements, and see
      // the effects of those changes when Haxe is invoked again.
      if (true) {
        ops.push(BOAlways(
          File('${config.buildPath}/${lib.config.name}/lib.$platformId.$ext'),
          WriteContent(lib.lb.done())
        ));
      }

      ops.push(BODependent(
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%OBJ%'),
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.$ext'),
        CompileObject(lib.config.language, {
          defines: lib.config.defines.concat(options.defines != null ? options.defines : []),
          includePaths: (options.includePaths != null ? options.includePaths : [])
            .concat(lib.config.includePaths),
        })
      ));
      var linkName = lib.outputPathRelative.split("/").pop();
      ops.push(BODependent(
        File('${config.outputPath}/${lib.outputPathRelative}'),
        File('${config.buildPath}/${lib.config.name}/lib.$platformId.%OBJ%'),
        LinkLibrary(lib.config.language, {
          defines: lib.config.defines.concat(options.defines != null ? options.defines : []),
          libraryPaths: (options.libraryPaths != null ? options.libraryPaths : [])
            .concat(lib.config.libraryPaths),
          libraries: (options.linkNames != null ? options.linkNames : [])
            .concat(lib.config.linkNames),
          linkName: linkName,
          frameworks: lib.config.frameworks,
          staticLibraries: [],
        })
      ));
    }
    return new BuildProgram(ops);
  }
}
