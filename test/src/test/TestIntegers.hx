#if macro

package test;

class TestIntegers extends TestBase {
  public function new() {
    super("TestIntegers");
    for (kind in [
      // TODO: these fail CI on Linux and Windows
      //{s: true,  m: marshal.int8(),   l1: macro 0x7F,                                    l2: macro -0x80                                  },
      //{s: true,  m: marshal.int16(),  l1: macro 0x7FFF,                                  l2: macro -0x8000                                },
      {s: true,  m: marshal.int32(),  l1: macro 0x7FFFFFFF,                              l2: macro -0x80000000                            },
      {s: true,  m: marshal.int64(),  l1: macro haxe.Int64.make(0x7FFFFFFF, 0xFFFFFFFF), l2: macro haxe.Int64.make(0x80000000, 0x00000000)},
      {s: false, m: marshal.uint8(),  l1: macro 0xFF,                                    l2: macro 0                                      },
      {s: false, m: marshal.uint16(), l1: macro 0xFFFF,                                  l2: macro 0                                      },
      {s: false, m: marshal.uint32(), l1: macro 0xFFFFFFFF,                              l2: macro 0                                      },
      {s: false, m: marshal.uint64(), l1: macro haxe.Int64.make(0xFFFFFFFF, 0xFFFFFFFF), l2: macro 0                                      },
    ]) {
      // value
      var f1 = lib.addFunction(kind.m, [kind.m], '_return = _arg0 + 2;');
      assertEq(macro {
        var v = 7;
        $f1(v);
      }, macro 9);
      if (kind.s) assertEq(macro $f1(-7), macro -5);

      // overflow
      var f2 = lib.addFunction(kind.m, [kind.m], '_return = _arg0 + 1;');
      assertEq(macro $f2(${kind.l1}), kind.l2);
    }
  }
}

#end
