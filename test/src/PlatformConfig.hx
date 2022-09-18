#if macro

typedef PlatformConfig =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp.CppConfig
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs.CsConfig
  #elseif AMMER_TEST_EVAL                     ammer.core.plat.Eval.EvalConfig
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink.HashlinkConfig
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java.JavaConfig
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua.LuaConfig
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko.NekoConfig
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs.NodejsConfig
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python.PythonConfig
  #else #error "no platform defined" #end
;

#end
