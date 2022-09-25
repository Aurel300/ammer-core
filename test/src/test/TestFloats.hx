#if macro

package test;

class TestFloats extends TestBase {
  public function new() {
    super("TestFloats");
    for (kind in [
      {m: marshal.float32() },
      {m: marshal.float64() },
      // {m: marshal.float128()},
    ]) {
      var f = lib.addFunction(kind.m, [kind.m], '_return = _arg0 * 2.0;');
      // TODO: epsilon?
      assertEq(macro $f(3.5),  macro 7.0,  kind.m.haxeType);
      assertEq(macro $f(-3.5), macro -7.0, kind.m.haxeType);
    }
  }
}

#end
