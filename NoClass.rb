

class NoClass

	def name
		"NULL"
	end

	def compile_class_load
		ret = "void load#{name}(Class_t class) {\n"
		ret += "\tclass->methods = malloc(sizeof(Method_t)* _dummyMethod);\n"
		ret += "\n}"
		ret
	end

	def compile_instance_members
		""
	end
end