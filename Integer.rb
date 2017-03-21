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


clazz.add_instance_method(JFFMethod.new(:equals, [:other],
			"\treturn other-value == this->value;\n"
))
