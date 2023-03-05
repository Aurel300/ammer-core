package ammer.core;

#if macro

enum abstract PlatformId(String) {
  var Cpp = "cpp";
  var Cs = "cs";
  var Eval = "eval";
  var Hashlink = "hashlink";
  var Java = "java";
  var Lua = "lua";
  var Neko = "neko";
  var Nodejs = "nodejs";
  var Python = "python";

  var None = "none";
}

#end
