require_relative "../config/environment.rb"
require 'active_support/inflector' #needed for pluralize

class Song

  def self.table_name
    # let's write a method that returns the name of a table, given the name of a class:
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    # query a table for the names of it's columns


    # iterate over the resulting array of hashes to collect just the name of each column. We call #compact on that just to be safe and get rid of any nil values that may end up in our collection.
    # The return value of calling Song.column_names will therefore be:
    # ["id", "name", "album"]

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
   column_names.compact
   #     this will return:
   # ["id", "name", "album"]
  end

  self.column_names.each do |col_name|
    # # attr_accessor named after each column name with the following code:
    # This is metaprogramming because we are writing code that writes code for us.
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    # argument of options, which defaults to an empty hash.
    # We expect #new to be called with a hash, so when we refer to options
    # inside the #initialize method, we expect to be operating on a hash.
    # We iterate over the options hash and use our fancy metaprogramming
    # send method to interpolate the name of each hash key as a method that we
    #set equal to that key's value. As long as each property has a corresponding
    # attr_accessor, this #initalize method will work.
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    # to use a class method inside an instance method, we need to do the following:
    # def some_instance_method
    #   self.class.some_class_method
    # end
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    # we don't INSERT the id attribute.
    # In fact, our Ruby object has an id of nil before it is inserted
    # into the table. The magic of our SQL database handles the creation of an
    # ID for a given table row and then we will use that ID to assign a value
    # to the original object's id attribute.
    # So, when we save our Ruby object, we should not include the id column name
    # or insert a value for the id column. Therefore, we need to remove "id"
    # from the array of column names
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #turn into a comma separated list, contained in a string:
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
