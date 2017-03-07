require './Method.rb'
require './Class.rb'

body = "return this == other;\n"

# m = JFFMethod.new(:equals, [:other], body)
# puts m.compile


puts ClassFactory.new.object.compile

