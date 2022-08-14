import haxe.macro.Context;
import haxe.macro.Expr;

class TestHarness {
  public static function build():Expr {
    var platformId =
      #if AMMER_TEST_CPP_STATIC "cpp-static" #end
      #if AMMER_TEST_CS "cs" #end
      #if AMMER_TEST_HL "hl" #end
      #if AMMER_TEST_HLC "hlc" #end
      #if AMMER_TEST_JAVA "java" #end
      #if AMMER_TEST_JVM "jvm" #end
      #if AMMER_TEST_LUA "lua" #end
      #if AMMER_TEST_NEKO "neko" #end
      #if AMMER_TEST_NODEJS "nodejs" #end
      #if AMMER_TEST_PYTHON "python" #end
      ;
    var gcMajor = macro
      #if AMMER_TEST_CPP_STATIC cpp.vm.Gc.run(true)
      #elseif (AMMER_TEST_HL || AMMER_TEST_HLC) hl.Gc.major()
      #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) java.vm.Gc.run(true)
      #elseif AMMER_TEST_LUA lua.Lua.collectgarbage(Collect)
      #elseif AMMER_TEST_NEKO neko.vm.Gc.run(true)
      #elseif AMMER_TEST_NODEJS (untyped global.gc())
      #elseif AMMER_TEST_PYTHON PythonGc.collect()
      #else {}
      #end
      ;

    function int(key:String):Null<Int> {
      var val = Context.definedValue('ammercoretest.$key');
      if (val == null || val == "") return null;
      return Std.parseInt(val);
    }
    function paths(key:String):Array<String> {
      var val = Context.definedValue('ammercoretest.$key');
      if (val == null || val == "") return null;
      return val.split(";");
    }

    var platform = ammer.core.Platform.createCurrentPlatform(({
      buildPath: 'bin/$platformId/ammer_build',
      outputPath: 'bin/$platformId',
      #if AMMER_TEST_HLC
        hlc: true,
      #end
      #if (AMMER_TEST_HL || AMMER_TEST_HLC)
        hlIncludePaths: paths("hl.includepaths"),
        hlLibraryPaths: paths("hl.librarypaths"),
      #end
      #if (AMMER_TEST_JAVA || AMMER_TEST_JVM)
        javaIncludePaths: paths("java.includepaths"),
      #end
      #if AMMER_TEST_LUA
        luaIncludePaths: paths("lua.includepaths"),
        luaLibraryPaths: paths("lua.librarypaths"),
      #end
      #if AMMER_TEST_NEKO
        nekoIncludePaths: paths("neko.includepaths"),
        nekoLibraryPaths: paths("neko.librarypaths"),
      #end
      #if AMMER_TEST_PYTHON
        pythonVersionMinor: int("python.version"),
        pythonIncludePaths: paths("python.includepaths"),
        pythonLibraryPaths: paths("python.librarypaths"),
      #end
    } : PlatformConfig));

    var library = platform.createLibrary(({
      name: "example",
      #if AMMER_TEST_JVM
        jvm: true,
      #elseif AMMER_TEST_JAVA
        jvm: false,
      #end
    } : LibraryConfig));

    var context:TestContext = {
      platformId: platformId,
      gcMajor: gcMajor,
      library: library,
      marshal: library.marshal(),
    };
    TestContext.I = context;

    var testExprs:Array<Expr> = [];
    for (ctor in ([
      test.TestHaxe.new,
      #if !AMMER_TEST_CS
        test.TestArrays.new,
      #end
      test.TestBools.new,
      test.TestBytes.new,
      test.TestCallbacks.new,
      test.TestFloats.new,
      test.TestIntegers.new,
      test.TestStrings.new,
      test.TestStructs.new,
    ]:Array<()->TestBase>)) {
      var test = ctor();
      testExprs.push(test.done());
    }

    platform.addLibrary(library);
    var program = platform.finalise();
    program.build();

    return macro $b{testExprs};
  }
}
