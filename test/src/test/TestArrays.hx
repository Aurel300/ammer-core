#if macro

package test;

class TestArrays extends TestBase {
  public function new() {
    super("TestArrays");
    testPrimitives();
  }

  function testPrimitives():Void {
    var type = marshal.arrayPtr(marshal.int32());
    scope(() -> {
      run(macro var array = $e{type.alloc(macro 8)});
      run(macro for (i in 0...8) {
        $e{type.set(macro array, macro i, macro 3 + i * 2)};
      });
      run(gcMajor);
      assertEq(macro $e{type.get(macro array, macro 3)}, macro 9);
      run(type.free(macro array));
    });
  }
}

#end
