package ammer.core.plat;

#if macro

typedef BaseFieldRef<TTypeMarshal> = {
  name:String,
  type:TTypeMarshal,
  ?read:Bool, // generate a getter function; default: true
  ?write:Bool, // generate a setter function; default: true
  ?ref:Bool, // generate a function to get a pointer to the field; default: true
  // TODO: other flags?
};

#end
