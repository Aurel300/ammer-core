package ammer.core.utils;

#if macro

import haxe.macro.Expr;
import haxe.macro.Type;

class Mangle {
  public static function identifier(name:String):String {
    return [ for (i in 0...name.length) {
      var cc = name.charCodeAt(i);
      if ((cc >= "0".code && cc <= "9".code)
        || (cc >= "A".code && cc <= "Z".code)
        || (cc >= "a".code && cc <= "z".code)) String.fromCharCode(cc);
      else if (cc < 0x100) "_" + StringTools.hex(cc, 2);
      else if (cc < 0x10000) "_u" + StringTools.hex(cc, 4);
      else "_uu" + StringTools.hex(cc, 6);
    } ].join("");
  }

  public static function parts(parts:Array<String>):String {
    return parts.map(identifier).join("__");
  }

  public static function complexType(t:ComplexType):String {
    return (switch (t) {
      case _: "haxetype"; // TODO
    });
  }

  public static function type(t:Type):String {
    return (switch (t) {
      case TInst(_): "haxetype"; // TODO
      case _: throw "unsupported";
    });
  }
}

#end
