import haxe.macro.Expr;

class TestHarness {
  public static function build():Expr {
    var library = new Library({
      name: "example",
      #if AMMER_TEST_JVM
        jvm: true,
      #elseif AMMER_TEST_JAVA
        jvm: false,
      #end
    });

    var context:TestContext = {
      platformId:
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
      ,
      gcMajor: macro
        #if AMMER_TEST_CPP_STATIC cpp.vm.Gc.run(true)
        #elseif (AMMER_TEST_HL || AMMER_TEST_HLC) hl.Gc.major()
        #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) java.vm.Gc.run(true)
        #elseif AMMER_TEST_LUA lua.Lua.collectgarbage(Collect)
        #elseif AMMER_TEST_NEKO neko.vm.Gc.run(true)
        #elseif AMMER_TEST_NODEJS (untyped global.gc())
        #elseif AMMER_TEST_PYTHON PythonGc.collect()
        #else {}
        #end
      ,
      library: library,
      marshal: library.marshal,
    };
    TestContext.I = context;

    var testExprs:Array<Expr> = [];
    for (ctor in ([
      test.TestArrays.new,
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

    var plat = new Platform({
      buildPath: 'bin/${context.platformId}/ammer_build',
      outputPath: 'bin/${context.platformId}',
      #if AMMER_TEST_HLC
        hlc: true,
      #end
      // TODO: define paths in local config
      #if (AMMER_TEST_JAVA || AMMER_TEST_JVM)
        javaIncludePaths: [
          "/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home/include",
          "/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home/include/darwin",
        ],
      #end
      #if AMMER_TEST_LUA
        luaIncludePaths: ["/DevProjects/Repos/ammer-lua/lua-5.3.5/src"],
        luaLibraryPaths: ["/DevProjects/Repos/ammer-lua/lua-5.3.5/src"],
      #end
      #if AMMER_TEST_NEKO
        nekoIncludePaths: ["/DevProjects/Repos/neko/build"],
        nekoLibraryPaths: ["/DevProjects/Repos/neko/build/bin"],
      #end
      #if AMMER_TEST_PYTHON
        pythonIncludePaths: ["/Library/Frameworks/Python.framework/Versions/3.6/include/python3.6m"],
        pythonLibraryPaths: ["/Library/Frameworks/Python.framework/Versions/3.6/lib"],
      #end
    });
    plat.addLibrary(library);
    var program = plat.finalise();
    program.defineTypes();
    program.build();

    return macro $b{testExprs};
  }
}
