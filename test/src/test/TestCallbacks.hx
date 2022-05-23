#if macro

package test;

class TestCallbacks extends TestBase {
  public function new() {
    super("TestCallbacks");
    var typeNative = cType("void* field_cl; void* field_cl2;");
    var closureType = marshal.closure(marshal.int32(), [marshal.int32(), marshal.int32()]);
    var closureType2 = marshal.closure(marshal.void(), []);
    var type = marshal.structPtr(typeNative, [{
      name: "field_cl",
      type: closureType.type,
      read: true,
      write: true,
      owned: true,
    }, {
      name: "field_cl2",
      type: closureType2.type,
      read: true,
      write: true,
      owned: true,
    }]);

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
          var cb = (a:Int, b:Int) -> {
            addLog.push('$a+$b');
            a + b;
          };
          var cb2 = () -> { callLog++; }
          $e{type.setters["field_cl"](macro struct, macro cb)};
          $e{type.setters["field_cl2"](macro struct, macro cb2)};
        }
      });
      run(macro nested());
      run(gcMajor);
      assertEq(macro $useCallback(struct, 1, 2), macro 3);
      run(gcMajor);
      assertEq(macro $useCallback(struct, 3, 4), macro 7);
      assertEq(macro $e{type.getters["field_cl"](macro struct)}(5, 6), macro 11);
      assertEq(macro addLog.join(","), macro "1+2,3+4,5+6");
      run(macro $e{type.getters["field_cl2"](macro struct)}());
      assertEq(macro callLog, macro 1);
      run(macro $useCallback2(struct));
      assertEq(macro callLog, macro 2);
      run(type.free(macro struct));
    });
  }
}

#end
