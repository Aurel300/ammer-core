package ammer.core;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

class Library {
  var kind:PlatformId;
  var library:Dynamic;

  function new(kind:PlatformId, library:Dynamic) {
    this.kind = kind;
    this.library = library;
  }

  public function marshal():MarshalSet {
    return @:privateAccess new MarshalSet(kind, (switch (kind) {
      case Cpp:      (cast library : ammer.core.plat.Cpp.CppLibrary).marshal;
      case Cs:       (cast library : ammer.core.plat.Cs.CsLibrary).marshal;
      case Hashlink: (cast library : ammer.core.plat.Hashlink.HashlinkLibrary).marshal;
      case Java:     (cast library : ammer.core.plat.Java.JavaLibrary).marshal;
      case Lua:      (cast library : ammer.core.plat.Lua.LuaLibrary).marshal;
      case Neko:     (cast library : ammer.core.plat.Neko.NekoLibrary).marshal;
      case Nodejs:   (cast library : ammer.core.plat.Nodejs.NodejsLibrary).marshal;
      case Python:   (cast library : ammer.core.plat.Python.PythonLibrary).marshal;
    }));
  }

  public function addInclude(include:SourceInclude):Void {
    library.addInclude(include);
  }

  public function addCode(code:String):Void {
    library.addCode(code);
  }

  public function addHeaderCode(code:String):Void {
    library.addHeaderCode(code);
  }

  public function addFunction(
    ret:TypeMarshal,
    args:Array<TypeMarshal>,
    code:String,
    ?options:FunctionOptions
  ):Expr {
    return library.addFunction(
      ret,
      args,
      code,
      options
    );
  }

  /*
  public function addNamedFunction(
        name:String,
        ret:TTypeMarshal,
        args:Array<TTypeMarshal>,
        code:String,
        options:FunctionOptions
      )
  public function closureCall(
        fn:String,
        clType:MarshalClosure<TTypeMarshal>,
        outputExpr:String,
        args:Array<String>
      )
  public function addCallback(
        ret:TTypeMarshal,
        args:Array<TTypeMarshal>,
        code:String
      )
  public function typeDefExpr()
  public function fieldExpr(field:String)
  */
}

#end
