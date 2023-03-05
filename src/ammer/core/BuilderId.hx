package ammer.core;

#if macro

enum abstract BuilderId(String) {
  var Gcc = "gcc";
  var Msvc = "msvc";

  // var None = "none";
}

#end
