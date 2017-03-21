require './Class.rb'

class ClassManager
	attr_reader :classes

	def initialize
		@classes = Hash.new
	end

	def class_with_name(name)
		if !@classes.has_key?(name) 
			@classes[name] = JFFClass.new(name)
		end
		@classes[name]
	end

	def self.instance
		@@instance ||= self.new
	end

end