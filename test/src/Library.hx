#if macro

typedef Library =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp.CppLibrary
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs.CsLibrary
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink.HashlinkLibrary
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java.JavaLibrary
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua.LuaLibrary
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko.NekoLibrary
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs.NodejsLibrary
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python.PythonLibrary
  #else #error "no platform defined" #end
;

#end
