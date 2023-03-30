package ammer.core;

#if macro

/**
Statements to include header files in the glue code.

See https://aurel300.github.io/ammer/ref-flags.html#lib.headers
**/
@:using(ammer.core.SourceInclude.SourceIncludeTools)
enum SourceInclude {
  IncludeLocal(path:String);
  IncludeGlobal(path:String);
  ImportLocal(path:String);
  ImportGlobal(path:String);
  // ... framewors etc?
}

class SourceIncludeTools {
  public static function toCode(include:SourceInclude):String {
    return (switch (include) {
      case IncludeLocal(path): '#include "$path"';
      case IncludeGlobal(path): '#include <$path>';
      case ImportLocal(path): '#import "$path"';
      case ImportGlobal(path): '#import <$path>';
    });
  }
}

#end
