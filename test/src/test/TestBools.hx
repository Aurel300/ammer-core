#if macro

package test;

class TestBools extends TestBase {
  public function new() {
    super("TestBools");
    var f = lib.addFunction(marshal.bool(), [marshal.bool()], '_return = !_arg0;');
    assertEq(macro $f(true),  macro false);
    assertEq(macro $f(false), macro true );
  }
}

#end
