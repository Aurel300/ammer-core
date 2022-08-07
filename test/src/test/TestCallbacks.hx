#if macro

package test;

class TestCallbacks extends TestBase {
  public function new() {
    super("TestCallbacks");
    var typeNative = cType("void* field_cl; void* field_cl2;");
    var closureType = marshal.closure(marshal.int32(), [marshal.int32(), marshal.int32()]);
    var closureType2 = marshal.closure(marshal.void(), []);
    var type = marshal.structPtr(typeNative, [
      marshal.fieldRef("field_cl", closureType.type),
      marshal.fieldRef("field_cl2", closureType2.type),
    ]);

    var callback = lib.addCallback(
      marshal.int32(),
      [
        type.type,
        marshal.int32(),
        marshal.int32(),
      ],
      lib.closureCall(
        "_arg0->field_cl",
        closureType,
        "_return",
        ["_arg1", "_arg2"]
      )
    );
    var useCallback = lib.addFunction(
      marshal.int32(),
      [
        type.type,
        marshal.int32(),
        marshal.int32(),
      ],
      '_return = $callback(_arg0, _arg1, _arg2);'
    );
    var callback2 = lib.addCallback(
      marshal.void(),
      [type.type],
      lib.closureCall(
        "_arg0->field_cl2",
        closureType2,
        "",
        []
      )
    );
    var useCallback2 = lib.addFunction(
      marshal.void(),
      [type.type],
      '$callback2(_arg0);'
    );

    scope(() -> {
      run(macro var struct = ${type.alloc});
      run(macro var addLog = []);
      run(macro var callLog = 0);
      run(macro function nested():Void {
        for (i in 0...1000) {
          var oldCb = $e{closureType.restore(type.fieldGet["field_cl"](macro struct))};
          if (oldCb != null) oldCb.decref();
          var oldCb2 = $e{closureType2.restore(type.fieldGet["field_cl2"](macro struct))};
          if (oldCb2 != null) oldCb2.decref();

          var cb = $e{closureType.create(macro (a:Int, b:Int) -> {
            addLog.push('$a+$b');
            a + b;
          })};
          cb.incref();
          var cb2 = $e{closureType2.create(macro () -> { callLog++; })};
          cb2.incref();
          $e{type.fieldSet["field_cl"](macro struct, macro cb.handle)};
          $e{type.fieldSet["field_cl2"](macro struct, macro cb2.handle)};
        }
      });
      run(macro nested());
      run(gcMajor);
      assertEq(macro $useCallback(struct, 1, 2), macro 3);
      run(gcMajor);
      assertEq(macro $useCallback(struct, 3, 4), macro 7);
      assertEq(macro $e{closureType.restore(type.fieldGet["field_cl"](macro struct))}.value(5, 6), macro 11);
      assertEq(macro addLog.join(","), macro "1+2,3+4,5+6");
      run(macro $e{closureType2.restore(type.fieldGet["field_cl2"](macro struct))}.value());
      assertEq(macro callLog, macro 1);
      run(macro $useCallback2(struct));
      assertEq(macro callLog, macro 2);
      run(type.free(macro struct));
    });
  }
}

#end
