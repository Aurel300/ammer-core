#if macro

typedef MarshalType =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp.CppTypeMarshal
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs.CsTypeMarshal
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink.HashlinkTypeMarshal
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java.JavaTypeMarshal
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua.LuaTypeMarshal
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko.NekoTypeMarshal
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs.NodejsTypeMarshal
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python.PythonTypeMarshal
  #else #error "no platform defined" #end
;

#end
