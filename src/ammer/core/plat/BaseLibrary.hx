package ammer.core.plat;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import ammer.core.utils.LineBuf;

@:allow(ammer.core.plat)
abstract class BaseLibrary<
  TSelf:BaseLibrary<
    TSelf,
    TLibraryConfig,
    TTypeMarshal,
    TMarshalSet
  >,
  TLibraryConfig:LibraryConfig,
  TTypeMarshal:BaseTypeMarshal,
  TMarshalSet:BaseMarshalSet<
    TMarshalSet,
    TLibraryConfig,
    TSelf,
    TTypeMarshal
  >
> {
  public var marshal:TMarshalSet;

  var config:TLibraryConfig;
  var tdef:TypeDefinition;
  var tdefs:Array<TypeDefinition> = [];
  var lb = new LineBuf();
  var functionNames:Map<String, Int> = new Map();

  function new(config:TLibraryConfig, marshal:TMarshalSet) {
    this.marshal = marshal;
    this.config = config;
    if (config.pos == null) config.pos = Context.currentPos();
    if (config.typeDefPack == null) config.typeDefPack = ["ammer", "externs"];
    if (config.typeDefName == null) config.typeDefName = 'CoreExtern_${config.name}';
    tdef = typeDefCreate();
  }

  function boilerplate(
    ctxType:String,
    keyType:String,
    registryNode:String,
    root:String,
    unroot:String
  ):String {
    // TODO: ctx might need to be per node (multi-threading ...)
    final BINS = 128;
    final P = '${config.internalPrefix}registry';
    /*
static void _ammer_core_registry_init($ctxType ctx) {
  _ammer_core_registry.ctx = ctx;
}
    */
    addCode('
// ammer core boilerplate
#include <stdlib.h>
// #include <stdio.h>
static size_t ${P}_hash(size_t key) {
  // taken from https://gist.github.com/badboy/6267743#64-bit-mix-functions
  // (by Thomas Wang)
  key = (~key) + (key << 21); // key = (key << 21) - key - 1;
  key = key ^ (key >> 24);
  key = (key + (key << 3)) + (key << 8); // key * 265
  key = key ^ (key >> 14);
  key = (key + (key << 2)) + (key << 4); // key * 21
  key = key ^ (key >> 28);
  key = key + (key << 31);
  return key % $BINS;
}
typedef struct ${P}_node_s {
  $keyType key;
  struct ${P}_node_s* next;
  int ref_count;
  $registryNode
} ${P}_node;
static struct {
  $ctxType ctx;
  ${P}_node null_node;
  ${P}_node* bins[$BINS];
} ${P};
static ${P}_node* ${P}_get($keyType key) {
  if (key == NULL) return &${P}.null_node;
  size_t bin = ${P}_hash((size_t)key);
  ${P}_node** next_ptr = &${P}.bins[bin];
  ${P}_node* curr = *next_ptr;
  while (curr != NULL) {
    if (curr->key == key) {
      return curr;
    }
    next_ptr = &curr->next;
    curr = *next_ptr;
  }
  curr = (${P}_node*)calloc(1, sizeof(${P}_node));
  curr->key = key;
  curr->ref_count = 0;
  *next_ptr = curr;
  return curr;
}
static void ${P}_incref(${P}_node* curr) {
  if (curr == NULL || curr == &${P}.null_node) return;
  if (curr->ref_count < 0) {
    // TODO: crash
    //puts("warning: ref_count < 0");
  }
  if (curr->ref_count == 0) {
    $root
  }
  curr->ref_count++;
  return;
}
static void ${P}_decref(${P}_node* curr) {
  if (curr == NULL || curr == &${P}.null_node) return;
  curr->ref_count--;
  if (curr->ref_count < 0) {
    // TODO: crash
    //printf("warning: decref ref_count < 0 for %p (%p)\\n", curr, curr->key);
  }
  if (curr->ref_count == 0) {
    size_t bin = ${P}_hash((size_t)curr->key);
    ${P}_node** next_ptr = &${P}.bins[bin];
    ${P}_node* curr_cmp = *next_ptr;
    while (curr_cmp != NULL) {
      if (curr == curr_cmp) {
        *next_ptr = curr->next;
        $unroot
        free(curr);
      }
      next_ptr = &curr_cmp->next;
      curr_cmp = *next_ptr;
    }
  }
}
// ammer core boilerplate end
');
    return P;
  }

  function mangleFunction(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    ?tag:String
  ):String {
    var crc = haxe.crypto.Crc32.make(haxe.io.Bytes.ofString(code));
    var name = '${config.internalPrefix}_${tag != null ? '${tag}_' : ""}${StringTools.hex(crc, 8)}_'
      + '${ret.mangled}__${args.map(arg -> arg.mangled).join("__")}';
    if (functionNames.exists(name)) {
      return '${name}__${functionNames[name]++}';
    } else {
      functionNames[name] = 0;
      return name;
    }
  }

  public function addInclude(include:SourceInclude):Void {
    lb.ail(include.toCode());
  }

  public function addCode(code:String):Void {
    lb.ail(code);
  }

  public function addHeaderCode(code:String):Void {
    // noop for most platforms
  }

  abstract public function addFunction(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String,
    ?pos:Position
  ):Expr;
  /*
  abstract public function storeOwned(
    native:String,
    c:String,
    type:TTypeMarshal
  ):String;

  abstract public function loadOwned(
    native:String,
    c:String,
    type:TTypeMarshal
  ):String;
*/
  abstract public function closureCall(
    fn:String,
    clType:MarshalClosure<TTypeMarshal>,
    outputExpr:String,
    args:Array<String>
  ):String;

  abstract public function addCallback(
    ret:TTypeMarshal,
    args:Array<TTypeMarshal>,
    code:String
  ):String;

  function typeDefCreate(addToDefs:Bool = true):TypeDefinition {
    var ret = {
      pos: config.pos,
      pack: config.typeDefPack,
      name: config.typeDefName,
      meta: [],
      kind: TDClass(
        null,
        [],
        false,
        true,
        false
      ),
      isExtern: false,
      fields: [],
    };
    if (addToDefs) {
      tdefs.push(ret);
    }
    return ret;
  }

  public function typeDefExpr():Expr {
    return macro $p{config.typeDefPack.concat([config.typeDefName])};
  }

  public function fieldExpr(field:String):Expr {
    return macro $p{config.typeDefPack.concat([config.typeDefName, field])};
  }
}

#end
