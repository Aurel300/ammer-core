#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

abstract class TestBase {
  static var printer = new haxe.macro.Printer();

  public var ctx:TestContext;
  public var output:Array<Expr> = [];
  public var outputStack:Array<Array<Expr>>;

  public var testId:String;
  public var gcMajor:Expr;
  public var lib:Library;
  public var marshal:Marshal;

  public function new(testId:String) {
    ctx = TestContext.I;
    this.testId = testId;
    gcMajor = ctx.gcMajor;
    lib = ctx.library;
    marshal = ctx.marshal;
    outputStack = [output];
    output.push(macro var _assertsPassed:Int = 0);
    output.push(macro var _assertsTotal:Int = 0);
  }

  function stringPos(p:Position):Expr {
    var loc = haxe.macro.PositionTools.toLocation(p);
    var str = '${loc.file} (${loc.range.start.line}:${loc.range.start.character} - ${loc.range.end.line}:${loc.range.end.character})';
    return macro $v{str};
  }

  public function scope(f:()->Void):Void {
    var oldTop = outputStack[outputStack.length - 1];
    outputStack.push(output = []);
    f();
    var inner = outputStack.pop();
    output = oldTop;
    #if AMMER_TEST_LUA
    // reduce local variable count ...
    output.push(macro if (untyped __lua__("1")) $b{inner});
    #else
    output.push(macro $b{inner});
    #end
  }

  public function run(e:Expr):Void {
    output.push(e);
  }

  public function assert(e:Expr):Void {
    var eStr = printer.printExpr(e);
    output.push(macro {
      _assertsTotal++;
      var _res:Bool = $e;
      if (_res) {
        _assertsPassed++;
      } else {
        Sys.println("assertion failed: " + $v{eStr} + " (" + $e{stringPos(e.pos)} + ")");
      }
    });
  }

  public function assertEq(l:Expr, r:Expr, ?typeHint:ComplexType):Void {
    var lStr = printer.printExpr(l);
    var rStr = printer.printExpr(r);
    var decls = typeHint != null
      ? macro @:mergeBlock { var _l:$typeHint = $l; var _r:$typeHint = $r; }
      : macro @:mergeBlock { var _l = $l;           var _r = $r;           };
    #if AMMER_TEST_LUA
    // reduce local variable count ...
    output.push(macro if (untyped __lua__("1")) {
    #else
    output.push(macro {
    #end
      _assertsTotal++;
      $decls;
      if (_l == _r) {
        _assertsPassed++;
      } else {
        Sys.println("assertion failed: " + $v{lStr} + " == " + $v{rStr} + " (" + $e{stringPos(l.pos)} + ")");
        Sys.println("  LHS is: " + _l);
        Sys.println("  RHS is: " + _r);
      }
    });
  }

  static var cTypeCtr = 0;
  public function cType(data:String):String {
    var ctr = cTypeCtr++;
    /*
    // allow direct field access:
    lib.addHeaderCode('typedef struct testtype_${ctr}_s {
  $data
} testtype_${ctr}_t;');
    */
    lib.addCode('typedef struct testtype_${ctr}_s {
  $data
} testtype_${ctr}_t;');
    lib.addHeaderCode('struct testtype_${ctr}_s;
typedef struct testtype_${ctr}_s testtype_${ctr}_t;');
    return 'testtype_${ctr}_t';
  }

  static var testCtr = 0;
  public function done():Expr {
    if (outputStack.length > 1) throw 0;
    output.push(macro Sys.println($v{testId} + " ... " + _assertsPassed + "/" + _assertsTotal));
    #if AMMER_TEST_LUA
    // reduce local variable count ...
    var tdef = macro class Test {
      public static function run():Void {
        $b{output}
      }
    };
    tdef.name = 'TestFragment${testCtr++}';
    Context.defineType(tdef);
    return macro $i{tdef.name}.run();
    #else
    return macro $b{output};
    #end
  }
}

#end
