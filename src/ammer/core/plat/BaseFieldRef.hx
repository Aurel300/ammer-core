package ammer.core.plat;

#if macro

typedef BaseFieldRef<TTypeMarshal> = {
  name:String,
  type:TTypeMarshal,
  read:Bool,
  write:Bool,
  ?owned:Bool, // root the value while it is in the struct; default: false
  // TODO: other flags?
};

#end
