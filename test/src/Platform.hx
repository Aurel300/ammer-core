#if macro

typedef Platform =
  #if AMMER_TEST_CPP_STATIC                   ammer.core.plat.Cpp
  #elseif AMMER_TEST_CS                       ammer.core.plat.Cs
  #elseif (AMMER_TEST_HL || AMMER_TEST_HLC)   ammer.core.plat.Hashlink
  #elseif (AMMER_TEST_JAVA || AMMER_TEST_JVM) ammer.core.plat.Java
  #elseif AMMER_TEST_LUA                      ammer.core.plat.Lua
  #elseif AMMER_TEST_NEKO                     ammer.core.plat.Neko
  #elseif AMMER_TEST_NODEJS                   ammer.core.plat.Nodejs
  #elseif AMMER_TEST_PYTHON                   ammer.core.plat.Python
  #else #error "no platform defined" #end
;

#end
