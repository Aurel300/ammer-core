#if macro

package test;

class TestArrays extends TestBase {
  public function new() {
    super("TestArrays");

    for (kind in [
      #if !(AMMER_TEST_NODEJS || AMMER_TEST_PYTHON) // TODO: u32 for u8,16...
      {m: marshal.int8(),    l: macro 0x7                                    },
      {m: marshal.int16(),   l: macro 0x700                                  },
      {m: marshal.uint8(),   l: macro 0x7                                    },
      {m: marshal.uint16(),  l: macro 0x700                                  },
      #end
      {m: marshal.int32(),   l: macro 0x70000                                },
      {m: marshal.uint32(),  l: macro 0x70000                                },
      #if !(AMMER_TEST_NODEJS || AMMER_TEST_PYTHON) // TODO: ?
      #if !AMMER_TEST_HLC // TODO: dyncast ...
      {m: marshal.int64(),   l: macro haxe.Int64.make(0xF0001324, 0xF0432100)},
      {m: marshal.uint64(),  l: macro haxe.Int64.make(0xF0001324, 0xF0432100)},
      #end
      #end
      #if !(AMMER_TEST_LUA || AMMER_TEST_NEKO || AMMER_TEST_NODEJS || AMMER_TEST_PYTHON)
      {m: marshal.float32(), l: macro 7                                      },
      #end
      {m: marshal.float64(), l: macro 7                                      },
    ]) {
      var type = marshal.arrayPtr(kind.m);
      var elType = kind.m.arrayType;
      if (elType == null) elType = kind.m.haxeType;
      var vectorTypePath = type.vectorTypePath;
      if (vectorTypePath == null) vectorTypePath = ammer.core.utils.TypeUtils.complexTypeToPath((macro : haxe.ds.Vector<$elType>));

      // TODO: the casts are not pretty...
      // native array
      scope(() -> {
        run(macro var array = $e{type.alloc(macro 8)});
        run(macro for (i in 0...8) {
          $e{type.set(macro array, macro i, macro $e{kind.l} + i * 2)};
        });
        assertEq(macro $e{type.get(macro array, macro 3)}, macro $e{kind.l} + 6, kind.m.haxeType);
        run(type.free(macro array));
      });

      // direct arrays by copy
      if (type.toHaxeCopy != null) scope(() -> {
        run(macro var array = $e{type.alloc(macro 8)});
        run(macro for (i in 0...8) {
          $e{type.set(macro array, macro i, macro $e{kind.l} + i * 2)};
        });
        run(macro var vector = $e{type.toHaxeCopy(macro array, macro 8)});
        assertEq(macro vector[3], macro (cast ($e{kind.l} + 6) : $elType));
        run(macro vector[2] = cast ($e{kind.l} + 42));
        assertEq(macro $e{type.get(macro array, macro 2)}, macro $e{kind.l} + 4);
        run(type.free(macro array));
      });
      if (type.fromHaxeCopy != null) scope(() -> {
        run(macro var vector = new $vectorTypePath(8));
        run(macro for (i in 0...8) {
          vector[i] = cast ($e{kind.l} + i * 2);
        });
        run(macro var array = $e{type.fromHaxeCopy(macro vector)});
        assertEq(macro $e{type.get(macro array, macro 3)}, macro $e{kind.l} + 6);
        run(type.set(macro array, macro 2, macro $e{kind.l} + 42));
        assertEq(macro vector[2], macro (cast ($e{kind.l} + 4) : $elType));
        run(type.free(macro array));
      });

      // direct arrays by reference
      // TODO: GC test
      if (type.toHaxeRef != null) scope(() -> {
        run(macro var array = $e{type.alloc(macro 8)});
        run(macro for (i in 0...8) {
          $e{type.set(macro array, macro i, macro $e{kind.l} + i * 2)};
        });
        run(macro var vector = $e{type.toHaxeRef(macro array, macro 8)});
        assertEq(macro vector[3], macro (cast ($e{kind.l} + 6) : $elType));
        run(macro vector[2] = cast ($e{kind.l} + 42));
        assertEq(macro $e{type.get(macro array, macro 2)}, macro $e{kind.l} + 42);
        run(type.free(macro array));
      });
      if (type.fromHaxeRef != null) scope(() -> {
        run(macro var vector = new $vectorTypePath(8));
        run(macro for (i in 0...8) {
          vector[i] = cast ($e{kind.l} + i * 2);
        });
        run(macro var array = $e{type.fromHaxeRef(macro vector)});
        assertEq(macro $e{type.get(macro array.ptr, macro 3)}, macro $e{kind.l} + 6);
        run(type.set(macro array.ptr, macro 2, macro $e{kind.l} + 42));
        run(macro array.unref());
        assertEq(macro vector[2], macro (cast ($e{kind.l} + 42) : $elType));
      });
    }
  }
}

#end
