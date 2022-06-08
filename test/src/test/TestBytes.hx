#if macro

package test;

class TestBytes extends TestBase {
  var bytesType:ammer.core.MarshalBytes<MarshalType>;

  public function new() {
    super("TestBytes");
    bytesType = marshal.bytes();

    // TODO: test ref variants with a GC step
    if (bytesType.fromBytesRef != null) scope(testFromBytesRef);
    if (bytesType.toBytesRef != null) scope(testToBytesRef);

    scope(testFromBytesCopy);
    scope(testToBytesCopy);
  }

  function testFromBytesRef():Void {
    run(macro var bytes = haxe.io.Bytes.ofString("hello world HELLO"));
    run(macro var nativeBytes = $e{bytesType.fromBytesRef(macro bytes)});

    assertEq(bytesType.get8 (macro nativeBytes.ptr, macro 0), macro "h".code  );
    assertEq(bytesType.get16(macro nativeBytes.ptr, macro 1), macro 0x6C65    );
    assertEq(bytesType.get32(macro nativeBytes.ptr, macro 3), macro 0x77206F6C);

    run(bytesType.set8 (macro nativeBytes.ptr, macro 5, macro 0x17      ));
    run(bytesType.set16(macro nativeBytes.ptr, macro 6, macro 0x1920    ));
    run(bytesType.set32(macro nativeBytes.ptr, macro 8, macro 0x22232425));

    run(macro nativeBytes.unref());

    assertEq(macro bytes.get      (5), macro 0x17      );
    assertEq(macro bytes.getUInt16(6), macro 0x1920    );
    assertEq(macro bytes.getInt32 (8), macro 0x22232425);
  }

  function testToBytesRef():Void {
    run(macro var nativeBytes = $e{bytesType.zalloc(macro 4)});
    assertEq(bytesType.get8(macro nativeBytes, macro 1), macro 0);
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xDEADFEED));
    run(macro var bytes = $e{bytesType.toBytesRef(macro nativeBytes, macro 4)});
    assertEq(macro bytes.getInt32(0), macro 0xDEADFEED);
    run(bytesType.free(macro nativeBytes));
  }

  function testFromBytesCopy():Void {
    run(macro var bytes = haxe.io.Bytes.ofString("hello world HELLO"));
    run(macro var nativeBytes = $e{bytesType.fromBytesCopy(macro bytes)});
    assertEq(bytesType.get16(macro nativeBytes, macro 1), macro 0x6C65);
    run(bytesType.set16(macro nativeBytes, macro 6, macro 0x1920));
    assertEq(macro bytes.getUInt16(6), macro 0x6F77);
  }

  function testToBytesCopy():Void {
    run(macro var nativeBytes = $e{bytesType.alloc(macro 4)});
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xDEADFEED));
    run(macro var bytes = $e{bytesType.toBytesCopy(macro nativeBytes, macro 4)});
    run(bytesType.set32(macro nativeBytes, macro 0, macro 0xCAFEFACE));
    assertEq(macro bytes.getInt32(0), macro 0xDEADFEED);
  }
}

#end
