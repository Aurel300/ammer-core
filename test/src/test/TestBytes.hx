#if macro

package test;

class TestBytes extends TestBase {
  var bytesType:ammer.core.MarshalBytes<ammer.core.TypeMarshal>;

  public function new() {
    super("TestBytes");
    bytesType = marshal.bytes();

    // TODO: test ref variants with a GC step
    if (bytesType.fromHaxeRef != null) scope(testFromHaxeRef);
    if (bytesType.toHaxeRef != null) scope(testToHaxeRef);

    scope(testFromHaxeCopy);
    scope(testToHaxeCopy);

    scope(testEndian);
    scope(testOffset);
  }

  function testFromHaxeRef():Void {
    run(macro var bytes = haxe.io.Bytes.ofString("hello world HELLO---"));
    run(macro var nativeBytes = $e{bytesType.fromHaxeRef(macro bytes)});

    assertEq(bytesType.get8 (macro nativeBytes.ptr, macro 0), macro "h".code  );
    assertEq(bytesType.get16(macro nativeBytes.ptr, macro 1), macro 0x6C65    );
    assertEq(bytesType.get32(macro nativeBytes.ptr, macro 3), macro 0x77206F6C);
    assertEq(bytesType.get64(macro nativeBytes.ptr, macro 7), macro haxe.Int64.make(0x4C454820, 0x646C726F));

    run(bytesType.set8 (macro nativeBytes.ptr, macro 5,  macro 0x17      ));
    run(bytesType.set16(macro nativeBytes.ptr, macro 6,  macro 0x1920    ));
    run(bytesType.set32(macro nativeBytes.ptr, macro 8,  macro 0x22232425));
    run(bytesType.set64(macro nativeBytes.ptr, macro 12, macro haxe.Int64.make(0x26272829, 0x30313233)));

    run(macro nativeBytes.unref());

    assertEq(macro bytes.get      (5),  macro 0x17      );
    assertEq(macro bytes.getUInt16(6),  macro 0x1920    );
    assertEq(macro bytes.getInt32 (8),  macro 0x22232425);
    assertEq(macro bytes.getInt64 (12), macro haxe.Int64.make(0x26272829, 0x30313233));
  }

  function testToHaxeRef():Void {
    run(macro var nativeBytes = $e{bytesType.zalloc(macro 4)});
    assertEq(bytesType.get8(macro nativeBytes, macro 1), macro 0);
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xDEADFEED));
    run(macro var bytes = $e{bytesType.toHaxeRef(macro nativeBytes, macro 4)});
    assertEq(macro bytes.getInt32(0), macro 0xDEADFEED);
    run(bytesType.free(macro nativeBytes));
  }

  function testFromHaxeCopy():Void {
    run(macro var bytes = haxe.io.Bytes.ofString("hello world HELLO"));
    run(macro var nativeBytes = $e{bytesType.fromHaxeCopy(macro bytes)});
    assertEq(bytesType.get16(macro nativeBytes, macro 1), macro 0x6C65);
    run(bytesType.set16(macro nativeBytes, macro 6, macro 0x1920));
    assertEq(macro bytes.getUInt16(6), macro 0x6F77);
  }

  function testToHaxeCopy():Void {
    run(macro var nativeBytes = $e{bytesType.alloc(macro 4)});
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xDEADFEED));
    run(macro var bytes = $e{bytesType.toHaxeCopy(macro nativeBytes, macro 4)});
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xCAFEFACE));
    assertEq(macro bytes.getInt32(0), macro 0xDEADFEED);
  }

  function testEndian():Void {
    run(macro var bytes = $e{bytesType.zalloc(macro 10)});
    run(macro $e{bytesType.set16(macro bytes, macro 0, macro 0xABCD)});
    run(macro var le = ($e{bytesType.get8(macro bytes, macro 0)} == 0xCD));

    run(macro $e{bytesType.set64(macro bytes, macro 0, macro haxe.Int64.make(0x01020304, 0x05060708))});
    assertEq(bytesType.get8 (macro bytes, macro 1), macro (le ? 0x07       : 0x02));
    assertEq(bytesType.get16(macro bytes, macro 1), macro (le ? 0x0607     : 0x0203));
    assertEq(bytesType.get32(macro bytes, macro 1), macro (le ? 0x04050607 : 0x02030405));
    assertEq(bytesType.get64(macro bytes, macro 1), macro (le ? haxe.Int64.make(0x00010203, 0x04050607) : haxe.Int64.make(0x02030405, 0x06070800)));

    run(macro $e{bytesType.free(macro bytes)});
    run(macro var bytes = $e{bytesType.zalloc(macro 8)});

    run(macro $e{bytesType.set16le(macro bytes, macro 0, macro 0x0102)});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x02);

    run(macro $e{bytesType.set32le(macro bytes, macro 0, macro 0x01020304)});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x04);

    run(macro $e{bytesType.set64le(macro bytes, macro 0, macro haxe.Int64.make(0x01020304, 0x05060708))});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x08);

    run(macro $e{bytesType.set16be(macro bytes, macro 0, macro 0x0102)});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x01);

    run(macro $e{bytesType.set32be(macro bytes, macro 0, macro 0x01020304)});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x01);

    run(macro $e{bytesType.set64be(macro bytes, macro 0, macro haxe.Int64.make(0x01020304, 0x05060708))});
    assertEq(bytesType.get8(macro bytes, macro 0), macro 0x01);
  }

  function testOffset():Void {
    run(macro var a = haxe.io.Bytes.ofString("hello world HELLO"));
    run(macro var b = $e{bytesType.fromHaxeCopy(macro a)});
    run(macro var c = $e{bytesType.offset(macro b, macro 6)});
    run(macro var d = $e{bytesType.toHaxeCopy(macro c, macro 11)});
    assertEq(macro d.toString(), macro "world HELLO");
  }
}

#end
