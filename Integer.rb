require './ClassManager.rb'


classMngr = ClassManager.instance

className = "Integer"
superclass = "Object"

clazz = classMngr.class_with_name(className)
meta = classMngr.class_with_name(className + "Class")

clazz.add_import_class(classMngr.class_with_name("String"))

meta.superclass = classMngr.class_with_name("Class")
clazz.metaclass = meta

clazz.superclass = classMngr.class_with_name("Object")
meta.superclass = classMngr.class_with_name("Class")


clazz.add_instance_member(JFFMember.new("int", "value"))


clazz.add_instance_method(JFFMethod.new(:init, :void, [{type: :int, name: :value}],
	"\tsuper(this, init);\n" +
	"\tthis->value = value;\n"
))

clazz.add_instance_method(JFFMethod.new(:equals, :int, [{type: :Object_t, name: :other}],
"\tif (other == this) return 1;\n" +
	"\tif (other == NULL) return 0;\n" +
	"\tif (sent(this, getClass) != send(other, getClass)) return 0;\n" +
	"\tInteger_t otherInteger = (Integer_t) other;\n" +
	"\treturn otherInteger->value == this->value;\n"
))

clazz.add_class_method(JFFMethod.new(:parse, :Integer_t, [{type: :String_t, name: :str}],
	"\treturn send(this, new, atoi(send(str, toCharArray)));\n"
))

