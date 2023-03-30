package ammer.core;

#if macro

/**
Identifier for builders known to `ammer-core`.
**/
enum abstract BuilderId(String) {
  var Gcc = "gcc";
  var Msvc = "msvc";

  // Unlike platforms, there is not yet a `None` version of a builder. Maybe
  // such a dummy builder would be useful for dry run debugging or when invoked
  // with `display`?
  //var None = "none";
}

#end
