class JFFMember
	attr_reader :type, :name
	def initialize(type, name)
		@type = type
		@name = name
	end

	def compile
		"#{type} #{name};"
	end
end