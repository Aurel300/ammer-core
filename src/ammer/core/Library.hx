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

  public function marshal():Marshal {
    return @:privateAccess new Marshal(kind, (switch (kind) {
      case Cpp:      (cast library : ammer.core.plat.Cpp.CppLibrary).marshal;
      case Cs:       (cast library : ammer.core.plat.Cs.CsLibrary).marshal;
      case Eval:     (cast library : ammer.core.plat.Eval.EvalLibrary).marshal;
      case Hashlink: (cast library : ammer.core.plat.Hashlink.HashlinkLibrary).marshal;
      case Java:     (cast library : ammer.core.plat.Java.JavaLibrary).marshal;
      case Lua:      (cast library : ammer.core.plat.Lua.LuaLibrary).marshal;
      case Neko:     (cast library : ammer.core.plat.Neko.NekoLibrary).marshal;
      case Nodejs:   (cast library : ammer.core.plat.Nodejs.NodejsLibrary).marshal;
      case Python:   (cast library : ammer.core.plat.Python.PythonLibrary).marshal;

      case None:     (cast library : ammer.core.plat.None.NoneLibrary).marshal;
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
  );
  */

  public function closureCall(
    fn:String,
    clType:MarshalClosure<TypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String {
    return library.closureCall(
      fn,
      clType,
      outputExpr,
      args
    );
  }

  public function staticCall(
    ret:TypeMarshal,
    args:Array<TypeMarshal>,
    code:Expr,
    outputExpr:String,
    argExprs:Array<String>
  ):String {
    return library.staticCall(
      ret,
      args,
      code,
      outputExpr,
      argExprs
    );
  }

  public function addCallback(
    ret:TypeMarshal,
    args:Array<TypeMarshal>,
    code:String
  ):String {
    return library.addCallback(
      ret,
      args,
      code
    );
  }

  public function addStaticCallback(
    ret:TypeMarshal,
    args:Array<TypeMarshal>,
    code:Expr
  ):String {
    return library.addStaticCallback(
      ret,
      args,
      code
    );
  }
}

#end
