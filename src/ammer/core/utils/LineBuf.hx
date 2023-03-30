package ammer.core.utils;

import haxe.ds.List;

using Lambda;

/**
Buffer for building strings/code. Similar to Haxe's `StringBuf`, but with
various convenience methods, indentation helpers, conditionals, etc. It also
has a fluent interface: most methods return the instance of `LineBuf` back in
their return, so they can easily be chained.

Similarly to `StringBuf`, `LineBuf` does not create a new string for every
append call.
**/
class LineBuf {
  /**
  The character or sequence of characters used as one level of indentation.
  **/
  var indent:String;

  /**
  The current indentation: zero or more repetitions of `indent`.
  **/
  var indentCurrent = "";

  /**
  The depth of the current indentation.
  **/
  var indentLevel = 0;

  /**
  Contents of this buffer.
  **/
  var data:List<String>;

  /**
  Length of the contents, in characters.
  **/
  var length = 0;

  /**
  Stack of the results of conditional evaluation (`ifi` etc).
  **/
  var condStack:Array<Bool> = [];
  // TODO: can probably be optimised away into two ints + bool?
  //var condLevel = 0;

  /**
  Whether the buffer is currently in an "executed" conditional.
  **/
  var condActive = true;

  public function new(indent:String = "  ") {
    data = new List();
    this.indent = indent;
  }

  /**
  Adds the contents of the given buffer directly, without stringifying its
  contents.
  **/
  public function addBuf(buf:LineBuf):LineBuf {
    @:privateAccess data.q.next = buf.data.h;
    @:privateAccess data.q = buf.data.q;
    buf.data = null;
    return this;
  }

  /**
  Calls the given function with `this` passed as the argument.
  **/
  public function apply(f:LineBuf->Void):LineBuf {
    f(this);
    return this;
  }

  /**
  Adds a string to the buffer.
  **/
  public inline function a(val:String):LineBuf {
    if (condActive) {
      data.add(val);
      length += val.length;
    }
    return this;
  }

  /**
  Adds a string to the buffer, followed by a linebreak.
  **/
  public inline function al(val:String):LineBuf {
    a(val);
    return a("\n");
  }

  /**
  Adds a string to the buffer, preceded by indentation.
  **/
  public inline function ai(val:String):LineBuf {
    a(indentCurrent);
    return a(val);
  }

  /**
  Adds a string to the buffer, preceded by indentation, followed by a linebreak.
  **/
  public inline function ail(val:String):LineBuf {
    a(indentCurrent);
    a(val);
    return a("\n");
  }

  /**
  Calls the given function for each element of the array, passing the element
  as the first argument and the buffer as the second.
  **/
  public function each<T>(arr:Array<T>, f:(T, LineBuf)->Void):LineBuf {
    for (el in arr)
      f(el, this);
    return this;
  }

  /**
  Calls the given function for each element of the array and appends the
  returned values to the buffer. `join` can optionally be used to add a string
  between the results.
  **/
  public function map<T>(arr:Array<T>, f:T->String, ?join:String):LineBuf {
    for (i => el in arr) {
      if (i != 0 && join != null)
        a(join);
      a(f(el));
    }
    return this;
  }

  /**
  Same as `map`, but additionally passes the index within the array as the
  first argument to the function.
  **/
  public function mapi<T>(arr:Array<T>, f:(Int, T)->String, ?join:String):LineBuf {
    for (i => el in arr) {
      if (i != 0 && join != null)
        a(join);
      a(f(i, el));
    }
    return this;
  }

  /**
  Calls the given function for each element of the array and appends the
  returned values to the buffer as separate lines with indentation. Empty lines
  are skipped.
  **/
  public function lmap<T>(arr:Array<T>, f:T->String):LineBuf {
    if (arr == null) return this;
    for (i => el in arr) {
      var line = f(el);
      if (line != "") ail(line);
    }
    return this;
  }

  /**
  Same as `lmap`, but additionally passes the index within the array as the
  first argument to the function.
  **/
  public function lmapi<T>(arr:Array<T>, f:(Int, T)->String):LineBuf {
    if (arr == null) return this;
    for (i => el in arr) {
      var line = f(i, el);
      if (line != "") ail(line);
    }
    return this;
  }

  /**
  Increases the indentation level by one.
  **/
  public function i():LineBuf {
    indentLevel++;
    indentCurrent += indent;
    return this;
  }

  /**
  Decreases the indentation level by one.
  **/
  public function d():LineBuf {
    if (indentLevel <= 0) throw "indent already zero";
    indentLevel--;
    indentCurrent = indentCurrent.substr(0, indentCurrent.length - indent.length);
    return this;
  }

  /**
  Opens a conditional block. Depending on the value of `cond`, calls to the
  buffer's append methods may be ignored, until an "else" (`ife`) or "end if"
  (`ifd`) is hit.
  **/
  public function ifi(cond:Bool):LineBuf {
    condStack.push(cond);
    if (!cond) condActive = false;
    return this;
  }

  /**
  Indicates an "else" branch of the last conditional block.
  **/
  public function ife():LineBuf {
    // TODO: forbid multiple "elses" ?
    if (condStack.length <= 0) throw "condition level already zero";
    condStack.push(!condStack.pop());
    condActive = !condStack.has(false);
    return this;
  }

  /**
  Closes the current conditional block.
  **/
  public function ifd():LineBuf {
    if (condStack.length <= 0) throw "condition level already zero";
    condStack.pop();
    condActive = !condStack.has(false);
    return this;
  }

  /**
  Shorthand for increasing the indentation level, calling the given function,
  then decreasing the indentation level again.
  **/
  public function b(f:LineBuf->Void):LineBuf {
    i();
    f(this);
    d();
    return this;
  }

  /**
  Finalises the buffer and returns its contents as a `String`. The buffer
  cannot be used after this call.
  **/
  public function done():String {
    if (indentLevel > 0) throw "LineBuf not at zero indentation level";
    if (condStack.length > 0) throw "LineBuf not at zero condition level";
    var ret = data.join("");
    data = null;
    return ret;
  }
}
