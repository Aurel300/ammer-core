package ammer.core.utils;

using Lambda;

class LineBuf {
  var indent:String;

  // TODO: make `data` into a linked list of (arrays of) strings
  //   -> can extend one LineBuf with another without stringifying
  //   -> can re-use indent strings
  //   keep track of total length
  //   then stringify into Bytes ?
  var data = new StringBuf();
  var indentCurrent = "";
  var indentLevel = 0;

  var condStack:Array<Bool> = [];
  // TODO: can probably be optimised away into two ints + bool?
  //var condLevel = 0;
  var condActive = true;

  public function new(indent:String = "  ") {
    this.indent = indent;
  }

  public inline function a(val:String):LineBuf {
    if (condActive) data.add(val);
    return this;
  }

  public inline function al(val:String):LineBuf {
    return a(val + "\n");
  }

  public inline function ai(val:String):LineBuf {
    return a(indentCurrent + val);
  }

  public inline function ail(val:String):LineBuf {
    return a(indentCurrent + val + "\n");
  }

  public function each<T>(arr:Array<T>, f:(T, LineBuf)->Void):LineBuf {
    for (el in arr)
      f(el, this);
    return this;
  }

  public function map<T>(arr:Array<T>, f:T->String, ?join:String):LineBuf {
    for (i => el in arr) {
      if (i != 0 && join != null)
        a(join);
      a(f(el));
    }
    return this;
  }

  public function mapi<T>(arr:Array<T>, f:(Int, T)->String, ?join:String):LineBuf {
    for (i => el in arr) {
      if (i != 0 && join != null)
        a(join);
      a(f(i, el));
    }
    return this;
  }

  public function lmap<T>(arr:Array<T>, f:T->String):LineBuf {
    for (i => el in arr) {
      var line = f(el);
      if (line != "") ail(line);
    }
    return this;
  }

  public function lmapi<T>(arr:Array<T>, f:(Int, T)->String):LineBuf {
    for (i => el in arr) {
      var line = f(i, el);
      if (line != "") ail(line);
    }
    return this;
  }

  public function i():LineBuf {
    indentLevel++;
    indentCurrent += indent;
    return this;
  }

  public function d():LineBuf {
    if (indentLevel <= 0) throw "indent already zero";
    indentLevel--;
    indentCurrent = indentCurrent.substr(0, indentCurrent.length - indent.length);
    return this;
  }

  public function ifi(cond:Bool):LineBuf {
    condStack.push(cond);
    if (!cond) condActive = false;
    return this;
  }

  public function ife():LineBuf {
    // TODO: forbid multiple "elses" ?
    if (condStack.length <= 0) throw "condition level already zero";
    condStack.push(!condStack.pop());
    condActive = !condStack.has(false);
    return this;
  }

  public function ifd():LineBuf {
    if (condStack.length <= 0) throw "condition level already zero";
    condStack.pop();
    condActive = !condStack.has(false);
    return this;
  }

  public function b(f:LineBuf->Void):LineBuf {
    i();
    f(this);
    d();
    return this;
  }

  public function done():String {
    if (indentLevel > 0) throw "LineBuf not at zero indentation level";
    if (condStack.length > 0) throw "LineBuf not at zero condition level";
    return data.toString();
  }
}
