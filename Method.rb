class JFFMethod
	attr_reader :name
	attr_accessor :clazz
	attr_reader :ret

	def initialize(aName, ret ,arguments, body)
		@name = aName
		@arguments = arguments
		@body = body
		@ret = ret
	end

	def compile
		signature + " {\n" + compile_arguments + compile_body + "\n}\n"
	end

	def compile_body
		@body
	end

	def signature
		"static #{ret} _#{clazz.name}_#{name}(#{clazz.name}_t this, va_list* va_arg)"
	end

	def compile_arguments
		ret = ""
		@arguments.each do | argument |
			ret += "\t#{argument[:type]} #{argument[:name]} = va_arg(*list, #{argument[:type]});\n"
		end
		ret
	end
end