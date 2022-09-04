package ammer.core;

enum BuildOp {
  BOCwd(
    path:String,
    sub:Array<BuildOp>
  );
  BOAlways(
    result:BuildOpResult,
    command:BuildOpCommand
  );
  BODependent(
    result:BuildOpResult,
    requires:BuildOpDependency,
    command:BuildOpCommand
  );
  // TODO: Haxe bakery
  // TODO: hot reload?
}

enum BuildOpResult {
  File(path:String);
}

enum BuildOpDependency {
  None;
  File(path:String);
  Directory(path:String);
}

enum BuildOpCommand {
  Phony;
  Copy;
  WriteContent(_:String);
  WriteData(_:haxe.io.Bytes);
  CompileObject(lang:LibraryLanguage, opt:MakeCompileOptions);
  LinkLibrary(lang:LibraryLanguage, opt:MakeLinkOptions);
  EnsureDirectory;
  Command(cmd:String, args:Array<String>);
}

typedef MakeCompileOptions = {
  defines:Array<String>,
  includePaths:Array<String>,
};

typedef MakeLinkOptions = {
  defines:Array<String>,
  libraryPaths:Array<String>,
  libraries:Array<String>,
  ?staticLibraries:Array<String>,
};
