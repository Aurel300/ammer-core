package ammer.core.build;

#if macro

class BuildProgram {
  public var ops:Array<BuildOp>;
  public function new(ops:Array<BuildOp>) {
    this.ops = ops;
  }
}

#end
