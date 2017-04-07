
# INITIAL
# 	CLASS
# 		REQUIRE
# 		PRE_CLASS_RAW
# 		REQUIRE
# 		CLASS PROPERTIES
# 			PROPERIES
# 			METHODS
# 		INSTANCE PROPERTIES
# 			PROPERIES
# 			METHODS
# 	POS_CLASS_RAW

module States
	INITIAL = InitialState
 	CLASS = ClassState
	REQUIRE = RequireState.new
	PRE_CLASS = 3
	CLASS_PROPS = 4
	INSTANCE_PROP = 5
	METHODS = 6
	POST_CLASS = 7

	class State
		attr_reader :valid, :next, :end
	end

	class InitialState < State
		def process(line)
			match = line.match clazz_open
			@valid = true
			@next = nil
			@end = false
			if match
				listener.class_start(match[:clazz], match[:superclass])
				@next = States::CLASS.new
			elsif line.chomp == "end"
				@end = true
			else
				@valid = false
			end
		end
	end
end


clazz_open = /class_open/
require_open = /require_open/
extra_headers_open = /extra_headers/
pre_class_open = /pre_class/
post_class_open = /post_class/
class_properties_open = /class_properties_open/
instance_properties_open = /instance_properties_open/
property_declaration = /property_declaration/
method_open = /method_open/

class Machine 
	attr_reader :states, :state, :listener
	def initialize(listener)
		@listener = listener
		@state = States::INITIAL.new
		@states = Array.new
	end

	def process(line)
		state.process(line)

		if state.valid?
			raise "Unexpected token: " + line
		end

		if state.next?
			states.push state
			state = state.next(listener)
			state.process(line)
		end
		if state.end?
			state = states.pop
		end
	end

	def valid?
		state.initial?
	end

end




