#if macro

typedef LibraryConfig =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp.CppLibraryConfig
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs.CsLibraryConfig
  #elseif AMMER_TEST_EVAL                     ammer.core.plat.Eval.EvalLibraryConfig
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink.HashlinkLibraryConfig
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java.JavaLibraryConfig
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua.LuaLibraryConfig
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko.NekoLibraryConfig
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs.NodejsLibraryConfig
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python.PythonLibraryConfig
  #else #error "no platform defined" #end
;

#end
