class JFFMethod
	attr_reader :name
	attr_accessor :clazz

	def initialize(aName, arguments, body)
		@name = aName
		@arguments = arguments
		@body = body
	end

	def compile
		compile_heading + compile_arguments + compile_body + "\n}\n"
	end

	def compile_body
		@body
	end

	def compile_heading
		"static Object_t _#{name}(#{clazz.name}_t this, va_list* va_arg) {\n"
	end

	def compile_arguments
		ret = ""
		@arguments.each do | argument |
			ret += "\tObject_t #{argument} = va_arg(*list, Object_t);\n"
		end
		ret
	end
end