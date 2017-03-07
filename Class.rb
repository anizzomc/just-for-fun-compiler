require './Member.rb'
require './Method.rb'

class JFFClass
	attr_reader :name, :superclass
	attr_accessor :metaclass

	def initialize(aName, aSuperClass, instance_members = [], class_members = [], imported_classes = [])
		@name = aName
		@superclass = aSuperClass
		@instance_methods = Array.new
		@class_methods = Array.new
		@instance_members = instance_members
		@imported_classes = imported_classes
		@extra_headers = []
	end

	def add_extra_headers(header)
		@extra_headers.push(header)
	end

	def add_import_class(clazz)
		@imported_classes.push(clazz)
	end

	def add_class_method(aMethod)
		metaclass.add_instance_method(aMethod)
	end

	def add_instance_method(aMethod)
		@instance_methods.push(aMethod)
	end

	def compile_include
		ret = ""
		@imported_classes.each do | clazz |
			ret += "#include <#{clazz.name}.h>\n"
		end
		ret
	end


	def compile_extra_headers
		ret = ""
		@extra_headers.each do | header |
			ret += "#include <#{header}.h>\n"
		end
		ret
	end

	def compile
		ret = ""
		ret += compile_include + "\n\n"
		ret += compile_extra_headers + "\n\n"
		ret += compile_struct + "\n\n"
		ret += compile_meta_struct + "\n\n"
		ret += compile_const_symbols + "\n\n"
		ret += compile_extra_prototypes + "\n\n"
		ret += compile_compile_method_prototypes + "\n\n"
		ret += compile_class_methods + "\n\n"
		ret += compile_instance_methods + "\n\n"
	end

	def compile_instance_methods
		ret = ""
		@instance_methods.each do |method|
			ret += method.compile
		end
		ret
	end

	def compile_class_methods
		metaclass.compile_instance_methods
	end

	def compile_compile_method_prototypes
		""
	end

	def compile_extra_prototypes
		""
	end

	def compile_const_symbols
		"static struct #{name}Class_c #{name.downcase} = {};\n" +
		"static struct Class_c #{name.downcase}Meta = {};\n\n" + 
		"const Class_t #{name} = &#{name.downcase};\n" + 
		"const Class_t #{name}Class = &#{name.downcase}Meta;\n"
	end

	def compile_header
		"#ifndef _#{name.upcase}_H_\n" + 
		"#define _#{name.upcase}_H_\n" +
		"#include <JFF.h>\n" + 
		"\n" +
		"void #{name.downcase}ClassLoad();\n\n" + 
		"typedef struct #{name}_c* #{name}_t;\n\n" + 
		"extern const Class_t #{name};\n\n" + 
		"#endif"
	end

	def compile_instance_members
		ret = @superclass.compile_instance_members
		@instance_members.each do |member|
			ret += "\t#{member.compile}\n"
		end
		ret
	end

	def compile_struct
		"stuct #{name}_c {\n" +
			"#{compile_instance_members}" +
		"};"
	end

	def compile_meta_struct
		metaclass.compile_struct
	end

	
	def self.integer 
		self.new("Integer", 
				self.object, 
				[
					JFFMember.new("int", "value")
				],
				[],
				[string]
		)
	end

	def self.integer_meta 
		self.new("IntegerMeta", 
				self.meta_class, 
				[],
				[],
				[]
		)
	end


	def self.NoClass
		NoClass.new
	end

	def self.meta_class
		self.new("Class",
			self.object,
			[
				JFFMember.new("Class_t", "superclass"),
				JFFMember.new("char*", "name"),
				JFFMember.new("size_t", "instanceSize"),
				JFFMember.new("Method_t*", "methods"),

			]
			)
	end



end


class ClassFactory
	attr_reader :object

	def initialize
		@object = JFFClass.new(
			"Object", 
			NoClass.new, 
			[
				JFFMember.new("Class_t", "class")
			]
		)

		@object.add_extra_headers("stdlib")
		@object.add_extra_headers("strings")
		@object.add_extra_headers("stdio")
		@object.add_extra_headers("mm")
		@object.add_extra_headers("mm_pool")

		@class = JFFClass.new("Class",
			@object,
			[
				JFFMember.new("Class_t", "superclass"),
				JFFMember.new("char*", "name"),
				JFFMember.new("size_t", "instanceSize"),
				JFFMember.new("Method_t*", "methods"),

			]
		)
		@object.metaclass = @class
		@string = JFFClass.new("String", 
				@object
		)

		object_equals = JFFMethod.new(:equals, [:other],
			"\treturn other == this;\n"

		)
		object_class_new = JFFMethod.new(:new, [],
  			"\tObject_t obj = D_mm_pool_add(D_mm_alloc(class->instanceSize, _dealloc_handler));\n" +
  			"\tobj->class = class;\n" +
  			"\tclass->methods[init](obj, list);\n"+
  			"\treturn obj;\n"
		)

		@object.add_class_method(object_class_new)
		@object.add_instance_method(object_equals)

		@object.add_import_class(@string)
	end



end

class NoClass
	def compile_instance_members
		""
	end
end