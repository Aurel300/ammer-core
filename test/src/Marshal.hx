#if macro

typedef Marshal =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp.CppMarshalSet
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs.CsMarshalSet
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink.HashlinkMarshalSet
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java.JavaMarshalSet
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua.LuaMarshalSet
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko.NekoMarshalSet
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs.NodejsMarshalSet
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python.PythonMarshalSet
  #else #error "no platform defined" #end
;

#end
