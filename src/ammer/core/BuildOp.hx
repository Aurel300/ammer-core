package ammer.core;

import ammer.core.LibraryConfig.LibraryAbi;

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
  CompileObject(abi:LibraryAbi, opt:MakeCompileOptions);
  LinkLibrary(abi:LibraryAbi, opt:MakeLinkOptions);
  EnsureDirectory;
  Command(cmd:String, args:Array<String>);
}

typedef MakeCompileOptions = {
  includePaths:Array<String>,
};

typedef MakeLinkOptions = {
  defines:Array<String>,
  libraryPaths:Array<String>,
  libraries:Array<String>,
  ?staticLibraries:Array<String>,
};
