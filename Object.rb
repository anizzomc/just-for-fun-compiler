require './ClassManager.rb'
require './NoClass.rb'


classMngr = ClassManager.instance

clazz = classMngr.class_with_name("Object")
meta = classMngr.class_with_name("Class")

clazz.add_import_class(classMngr.class_with_name("String"))

meta.superclass = clazz
clazz.metaclass = meta

clazz.superclass = NoClass.new

clazz.add_extra_headers("stdlib")
clazz.add_extra_headers("strings")
clazz.add_extra_headers("stdio")
clazz.add_extra_headers("mm")
clazz.add_extra_headers("mm_pool")


clazz.add_instance_member(JFFMember.new("Class_t", "class"))

meta.add_instance_member(JFFMember.new("Class_t", "superclass"))
meta.add_instance_member(JFFMember.new("char*", "name"))
meta.add_instance_member(JFFMember.new("size_t", "instanceSize"))
meta.add_instance_member(JFFMember.new("Method_t*", "methods"))



clazz.add_instance_method(JFFMethod.new(:equals, :int, [{type: :Object_t, name: :other}],
			"\treturn other == this;\n"
))

meta.add_instance_method(JFFMethod.new(:new, :Object_t, [],
	"\tObject_t obj = D_mm_pool_add(D_mm_alloc(class->instanceSize, _dealloc_handler));\n" +
	"\tobj->class = class;\n" +
	"\tclass->methods[init](obj, list);\n"+
	"\treturn obj;\n"
))



