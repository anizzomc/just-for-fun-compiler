require './ClassManager.rb'


require './Object.rb'
require './Integer.rb'

puts ClassManager.instance.class_with_name("Integer").compile

puts ClassManager.instance.principal_classes

