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

    var platform = ammer.core.Platform.createCurrentPlatform(({
      buildPath: 'bin/$platformId/ammer_build',
      outputPath: 'bin/$platformId',
      #if AMMER_TEST_HLC
        hlc: true,
      #end
      // TODO: define paths in local config
      #if (AMMER_TEST_JAVA || AMMER_TEST_JVM)
        javaIncludePaths: Context.definedValue("ammercoretest.java.includepaths").split(":"),
      #end
      #if AMMER_TEST_LUA
        luaIncludePaths: Context.definedValue("ammercoretest.lua.includepaths").split(":"),
        luaLibraryPaths: Context.definedValue("ammercoretest.lua.librarypaths").split(":"),
      #end
      #if AMMER_TEST_NEKO
        nekoIncludePaths: Context.definedValue("ammercoretest.neko.includepaths").split(":"),
        nekoLibraryPaths: Context.definedValue("ammercoretest.neko.librarypaths").split(":"),
      #end
      #if AMMER_TEST_PYTHON
        pythonIncludePaths: Context.definedValue("ammercoretest.python.includepaths").split(":"),
        pythonLibraryPaths: Context.definedValue("ammercoretest.python.librarypaths").split(":"),
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
