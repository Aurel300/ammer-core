#if macro

import haxe.macro.Expr;

@:structInit
class TestContext {
  public static var I:TestContext;

  public var platformId:String;
  public var gcMajor:Expr;
  public var library:Library;
  public var marshal:Marshal;
  public var failed:Bool = false;
}

#end
