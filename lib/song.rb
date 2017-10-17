require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    #takes the name of the class, referenced by self keyword, converts it to a string, then
    #downcases and pluralizes it
    self.to_s.downcase.pluralize
    #this method grabs us the table name we want to query for colun names
  end

  def self.column_names
    #this method will actually grab us those column names (querying a table for column names)

    DB[:conn].results_as_hash = true  #we want results returned as a hash

    sql = "pragma table_info('#{table_name}')" #this is an sql query that is absttract and will return an array
    #of hashes describing the table itself; each hash will contain info about one column

    table_info = DB[:conn].execute(sql) #execute SQL and store return value (array of hashes) in variable
    column_names = [] #start with empty array, which you'll push into
    table_info.each do |row| #iterate over array of hashes, where each hash is a row
      column_names << row["name"] #collect just the name of each column and push to array
    end
    column_names.compact #just to be safe and get rid of any nil values that may end up in our collection.
  end

  self.column_names.each do |col_name| #iterate over array of column names
    attr_accessor col_name.to_sym #convert each column name to symbol then set as attribute. metaprogramming!
    #By setting the attr_accessors in this way, a reader and writer method for each column name is dynamically created,
    #without us ever having to explicitly name each of these methods.
  end

  def initialize(options={}) #So, we need to define our #initialize method to take in a hash of named, or keyword,
    #arguments. However, we don't want to explicitly name those arguments. we default to an empty hash
    options.each do |property, value|
      self.send("#{property}=", value)
    end
    #We iterate over the options hash (which defaults as empty) and use our fancy metaprogramming #send method to interpolate the name of
    #each hash key as a method that we set equal to that key's value. As long as each property has a
    #corresponding attr_accessor, this #initialize method will work.
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})" #using methods
    #defined below to abstract values for reusable code!
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]#same here
  end

  def table_name_for_insert
    self.class.table_name #so we have access to a class method within an instance method. We're setting the table name here??
  end

  def values_for_insert
    values = [] #start with empty array
    self.class.column_names.each do |col_name| #class method in an instance method. iterate over array returned below
      values << "'#{send(col_name)}'" unless send(col_name).nil?  #use send to involke method with same name as column???
      #wrapping that return value as a string, as you are tying to craft a string of sql. then push return value to array?
    end
    values.join(", ") #turn array into comma-separated list
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #when we save our Ruby object, we should not include the id column name or insert a value for the id column. Therefore,
    #we need to remove "id" from the array of column names returned from the method call above:
    #note that the return value for this method is an array what is left, i.e. the columns we want, not what is deleted.
    #the join will turn this array into a comma-separated list
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'" #calling first method to abstract table name. but also interpolatig name???
    DB[:conn].execute(sql)
  end

end
