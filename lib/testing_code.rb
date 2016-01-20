class Bob
	attr_accessor :name, :id
	def initialize(options={})
	  options.each do |property, value|
	    self.send("#{property}=", value)
	  end
	end

end

b = Bob.new(name: "fred", id: 1)
print b.id

