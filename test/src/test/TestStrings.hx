#if macro

package test;

class TestStrings extends TestBase {
  public function new() {
    super("TestStrings");
    var f = lib.addFunction(
      marshal.string(),
      [marshal.string()],
      // TODO: non-BMP Unicode on Java fails (modified UTF-8 encoding...)
      //'_return = strdup(strcmp(_arg0, "hello\\U0001F404") == 0 ? "good" : "bad");'
      '_return = strdup(strcmp(_arg0, "hello") == 0 ? "good" : "bad");'
    );
    //assertEq(macro $f("hello\u{1F404}"), macro "good");
    assertEq(macro $f("hello"), macro "good");
  }
}

#end
