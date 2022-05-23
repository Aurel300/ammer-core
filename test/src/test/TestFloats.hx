#if macro

package test;

class TestFloats extends TestBase {
  public function new() {
    super("TestFloats");
    for (kind in [
      #if !(AMMER_TEST_LUA || AMMER_TEST_NEKO || AMMER_TEST_NODEJS || AMMER_TEST_PYTHON)
      {m: marshal.float32() },
      #end
      {m: marshal.float64() },
      // {m: marshal.float128()},
    ]) {
      var f = lib.addFunction(kind.m, [kind.m], '_return = _arg0 * 2.0;');
      // TODO: epsilon?
      assertEq(macro $f(3.21),  macro 6.42 , kind.m.haxeType);
      assertEq(macro $f(-3.21), macro -6.42, kind.m.haxeType);
    }
  }
}

#end
