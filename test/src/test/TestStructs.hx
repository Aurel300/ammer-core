#if macro

package test;

class TestStructs extends TestBase {
  public function new() {
    super("TestStructs");
    testPrimitives();
    testBoxes();
    testOwned();
    testNested();
  }

  function testPrimitives():Void {
    // TODO: test all primitive types? see arrays
    var typeNative = cType("int field_int;");
    var type = marshal.structPtr(typeNative, [
      marshal.fieldRef("field_int", marshal.int32()),
    ]);
    scope(() -> {
      run(macro var struct = $e{type.alloc});
      run(type.fieldSet["field_int"](macro struct, macro 42));
      assertEq(type.fieldGet["field_int"](macro struct), macro 42);
      run(type.free(macro struct));
    });
  }

  function testBoxes():Void {
    for (kind in [
      {m: marshal.int8(),    l: macro 0x7                                    },
      {m: marshal.int16(),   l: macro 0x700                                  },
      {m: marshal.uint8(),   l: macro 0x7                                    },
      {m: marshal.uint16(),  l: macro 0x700                                  },
      {m: marshal.int32(),   l: macro 0x70000                                },
      {m: marshal.uint32(),  l: macro 0x70000                                },
      #if !AMMER_TEST_HLC // TODO: dyncast ...
      {m: marshal.int64(),   l: macro haxe.Int64.make(0xF0001324, 0xF0432100)},
      {m: marshal.uint64(),  l: macro haxe.Int64.make(0xF0001324, 0xF0432100)},
      #end
      #if !(AMMER_TEST_EVAL || AMMER_TEST_LUA || AMMER_TEST_NEKO || AMMER_TEST_NODEJS || AMMER_TEST_PYTHON)
      {m: marshal.float32(), l: macro 7                                      },
      #end
      {m: marshal.float64(), l: macro 7                                      },
    ]) {
      var type = marshal.boxPtr(kind.m);
      scope(() -> {
        run(macro var box = $e{type.alloc});
        run(type.set(macro box, kind.l));
        assertEq(type.get(macro box), kind.l);
      });
    }
  }

  function testOwned():Void {
    var typeHaxe = marshal.haxePtr((macro : ExampleType));
    var typeNative = cType("void* field_haxe;");
    var type = marshal.structPtr(typeNative, [
      marshal.fieldRef("field_haxe", typeHaxe.type),
    ]);

    scope(() -> {
      run(macro function nested(target):Void {
        var ref = $e{typeHaxe.create(macro new ExampleType(42))};
        ref.incref();
        $e{type.fieldSet["field_haxe"](macro target, macro ref.handle)};
      });
      run(macro var struct = $e{type.alloc});
      run(macro nested(struct));
      run(gcMajor);
      assertEq(macro $e{typeHaxe.restore(type.fieldGet["field_haxe"](macro struct))}.value.val, macro 42);
      run(type.free(macro struct));
    });
  }

  function testNested():Void {
    var typeInnerNative = cType("int val;");
    var typeOuterNative = cType('${typeInnerNative} embedded; ${typeInnerNative}* ptr;');
    var typeInner = marshal.structPtr(typeInnerNative, [
      marshal.fieldRef("val", marshal.int32()),
    ]);
    var typeOuter = marshal.structPtr(typeOuterNative, [
      marshal.fieldRef("embedded", typeInner.typeDeref),
      marshal.fieldRef("ptr", typeInner.type),
    ]);
    var typeBoxInt = marshal.boxPtr(marshal.int32());

    scope(() -> {
      run(macro var inner = $e{typeInner.alloc});
      run(macro var outer = $e{typeOuter.alloc});

      run(typeOuter.fieldSet["ptr"](macro outer, macro inner));
      run(typeInner.fieldSet["val"](macro inner, macro 7));
      assertEq(typeInner.fieldGet["val"](typeOuter.fieldGet["ptr"](macro outer)), macro 7);

      run(macro var valRef = $e{typeInner.fieldRef["val"](macro inner)});
      run(typeBoxInt.set(macro valRef, macro 9));
      assertEq(typeInner.fieldGet["val"](typeOuter.fieldGet["ptr"](macro outer)), macro 9);

      run(typeOuter.fieldSet["embedded"](macro outer, macro inner));
      run(typeInner.fieldSet["val"](macro inner, macro 17));
      assertEq(typeInner.fieldGet["val"](typeOuter.fieldGet["embedded"](macro outer)), macro 9);
    });
  }
}

#end
