#if macro

package test;

class TestStructs extends TestBase {
  public function new() {
    super("TestStructs");
    testPrimitives();
    testOwned();
  }

  function testPrimitives():Void {
    var typeNative = cType("int field_int;");
    var type = marshal.structPtr(typeNative, [{
      name: "field_int",
      type: marshal.int32(),
      read: true,
      write: true,
    }]);
    scope(() -> {
      run(macro var struct = $e{type.alloc});
      run(type.setters["field_int"](macro struct, macro 42));
      assertEq(type.getters["field_int"](macro struct), macro 42);
      run(type.free(macro struct));
    });
  }

  function testOwned():Void {
    var typeNative = cType("void* field_haxe;");
    var type = marshal.structPtr(typeNative, [{
      name: "field_haxe",
      type: marshal.haxePtr((macro : Main.ExampleType)),
      read: true,
      write: true,
      owned: true,
    }]);

    scope(() -> {
      run(macro function nested(target):Void {
        $e{type.setters["field_haxe"](macro target, macro new ExampleType(42))};
      });
      run(macro var struct = $e{type.alloc});
      run(macro nested(struct));
      run(gcMajor);
      assertEq(macro $e{type.getters["field_haxe"](macro struct)}.val, macro 42);
      run(type.free(macro struct));
    });
  }
}

#end
