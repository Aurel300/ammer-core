#if macro

package test;

class TestHaxe extends TestBase {
  public function new() {
    super("TestHaxe");

    var type = marshal.haxePtr((macro : ExampleType));
    lib.addCode("void* testhaxe_storage = 0;");
    var setHaxe = lib.addFunction(
      marshal.void(),
      [type.type],
      'testhaxe_storage = _arg0;'
    );
    var getHaxe = lib.addFunction(
      type.type,
      [],
      '_return = testhaxe_storage;'
    );
    scope(() -> {
      run(macro function store():Void {
        var val = new ExampleType(42);
        var ref = $e{type.create(macro val)};
        ref.incref();
        $setHaxe(ref.handle);
      });
      run(macro store());
      run(gcMajor);
      run(macro var ref = $e{type.restore(macro $getHaxe())});
      assertEq(macro ref.value.val, macro 42);
      run(macro ref.decref());
    });
  }
}

#end
