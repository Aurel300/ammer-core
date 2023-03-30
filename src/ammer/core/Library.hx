package ammer.core;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

/**
A wrapper for `ammer.core.plat.(Platform).(Platform)Library` types.

See https://aurel300.github.io/ammer/core-api.html#library
**/
class Library {
  var kind:PlatformId;
  var library:Dynamic;

  function new(kind:PlatformId, library:Dynamic) {
    this.kind = kind;
    this.library = library;
  }

  /**
  Returns the instance of `Marshal` for this library. Do not use a `Marshal`
  instance returned by one library with another library.
  **/
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

  public function outputPathRelative():String {
    return this.library.outputPathRelative;
  }

  /**
  Adds the given include to the generated code.
  **/
  public function addInclude(include:SourceInclude):Void {
    library.addInclude(include);
  }

  /**
  Adds the given code directly to the generated code. No additional wrapping
  will be performed, so this can be used to inject new C functions etc.
  **/
  public function addCode(code:String):Void {
    library.addCode(code);
  }

  /**
  Same as `addCode`, but only adds the given code to the header. No-op for most
  platforms (because there are no header files generated), except for `Cpp`.
  **/
  public function addHeaderCode(code:String):Void {
    library.addHeaderCode(code);
  }

  /**
  Adds the given function to the generated code.

  - `ret` - the return type.
  - `args` - the types of the arguments.
  - `code` - the C code of body of the function.
  - `options` - additional options.

  `code` should be *only* the body of the function, without the signature, any
  braces, etc. This is because the platform will take care of declaring the
  function with the correct signature. It will also marshal the arguments from
  the target's native representation into C types and vice versa for the return
  value.

  Within `code`, the variables `_arg0`, `_arg1`, etc can be used to refer to
  the arguments passed to the function. For non-void functions, `_return` is a
  variable which contains the returned value. Do not use a `return` statement
  directly!
  **/
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

  /**
  Returns a fragment of C code that will perform a call to a Haxe closure.

  - `fn` - a C expression, the reference to a Haxe closure.
  - `clType` - the type of the closure.
  - `outputExpr` - the expression to write the result of the call into.
  - `args` - the arguments (C expressions) to use in the call.
  **/
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

  /**
  Returns a fragment of C code that will invoke Haxe code. The code should not
  depend on any closure capture or context (it will be placed in the body of a
  standalone `static function`).

  - `ret` - the return type.
  - `args` - the types of the arguments.
  - `code` - Haxe code to call.
  - `outputExpr` - the C expression to write the result of the call into.
  - `argExprs` - the arguments (C expressions) to use in the call.

  Within `code`, the variables `arg0`, `arg1`, etc can be used to refer to the
  arguments passed to the function.
  **/
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

  /**
  Adds a callback to the generated code. This will be a function with the
  signature expected by a C library, callable from C. Returns the name of the
  generated function.

  - `ret` - the return type.
  - `args` - the types of the arguments.
  - `code` - code to be called when the callback is invoked.

  For callbacks which are meant to actually call back into Haxe code, it may be
  useful to use `closureCall` to generate the `code` argument.
  **/
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

  /**
  Convenience shorthand, combines `addCallback` and `staticCall` such that the
  given Haxe `code` is invoked when the native library calls the generated
  callback function. Returns the name of the generated function.
  **/
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
