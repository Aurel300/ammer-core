#if !macro

#if AMMER_TEST_PYTHON
@:pythonImport("gc")
extern class PythonGc {
  static function collect():Void;
}
#end

class Main {
  public static function main():Void {
    TestHarness.build();
  }
}

#end
