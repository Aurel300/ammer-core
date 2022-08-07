#if macro

import haxe.macro.Expr;

@:structInit
class TestContext {
  public static var I:TestContext;

  public var platformId:String;
  public var gcMajor:Expr;
  public var library:ammer.core.Library;
  public var marshal:ammer.core.Marshal;
  public var failed:Bool = false;
}

#end
