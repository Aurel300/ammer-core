package ammer.core.utils;

import haxe.macro.Expr;

class TypeUtils {
  public static function complexTypeToPath(t:ComplexType):TypePath {
    return (switch (t) {
      case TPath(tp): tp;
      case _: throw 0;
    });
  }

  public static function ffun(args:Array<ComplexType>, ret:ComplexType, ?expr:Expr):FieldType {
    return FFun({
      ret: ret,
      expr: expr,
      args: [ for (i => arg in args) {
        type: arg,
        name: 'arg$i',
      } ],
    });
  }

  public static function ffunCt(t:ComplexType, ?expr:Expr):FieldType {
    return (switch (t) {
      case TFunction(args, ret): FFun({
        ret: ret,
        expr: expr,
        args: [ for (i => arg in args) {
          type: arg,
          name: 'arg$i',
        } ],
      });
      case _: throw 0;
    });
  }
}
