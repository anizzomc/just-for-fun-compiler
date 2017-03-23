require './Member.rb'
require './Method.rb'

class JFFClass
	attr_reader :name
	attr_accessor :metaclass, :superclass

	def initialize(aName, aSuperClass = NoClass.new, instance_members = [], class_members = [], imported_classes = [])
		@name = aName
		@superclass = aSuperClass
		@instance_methods = Array.new
		@class_methods = Array.new
		@instance_members = instance_members
		@imported_classes = imported_classes
		@extra_headers = []
	end

	def meta?
		!metaclass.nil?
	end

	def add_instance_member(member)
		@instance_members.push(member)
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
		aMethod.clazz = self
		@instance_methods.push(aMethod)
	end

	def compile_include
		ret = "/* #{name}.c */\n\n"
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
		ret += compile_class_load + "\n\n"
		ret += compile_meta_class_load + "\n\n"
		ret += compile_general_load + "\n\n"
		ret
	end

	def methodz
		@instance_methods
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
		"const Class_t #{name}Class = &#{name.downcase}Meta;\n" +
		"const Class_t #{name}ClassClass = &#{name.downcase}Meta;\n"
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

	def compile_meta_class_load
		metaclass.compile_class_load
	end

	def compile_class_load
		ret = "void load#{name}(Class_t class) {\n"
		ret += "\tload#{superclass.name}(class);\n"
		ret += "\n";
		ret += "\t// Basic Properties\n";
		ret += "\tclass->class = #{name}Class;\n"
		ret += "\tclass->superclass = #{superclass.name};\n"
		ret += "\tclass->name = \"#{name}\";\n"
		ret += "\tclass->instanceSize = sizeof(struct #{name}_c);\n"
		ret += "\t\n"
		ret += "\t// Custom Properties\n"
		ret += "\t\n"
		ret += "\t//Instance Methods\n"

		@instance_methods.each do | method |
			ret += "\tclass->methods[#{method.name}] = &_#{method.clazz.name}_#{method.name};\n"
		end

		ret += "\n}"
		ret

	end

	def compile_general_load
		ret = "void #{name.downcase}ClassLoad(void) {\n"
		ret += "\tload#{name}(#{name});\n" 
		ret += "\tload#{metaclass.name}(#{metaclass.name});\n"
		ret += "}"
	end
end