require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name #- gets the table name, database itself must exist already
    self.to_s.downcase.pluralize
  end # this method returns a table name in a string - "songs"

  def self.column_names
    DB[:conn].results_as_hash = true # - makes "execute items on the database returns a hash instead of an array"

    sql = "pragma table_info('#{table_name}')" # pragma table_info (returns the table column headers) - for the table it calls what's in the parenthesis 

    table_info = DB[:conn].execute(sql) #this returns a array of hash that has key value pairs,  the "name" key has a value of the the column name. (each column is seperated in it's own array of hashes)
    column_names = []
    table_info.each do |row|
      column_names << row["name"] #shovels the values of a key called "name" into the column_names array
    end 
    column_names.compact #compact gets rid of all nil items in array.
  end # this method returns an array of column names - id, name, album

  self.column_names.each do |col_name| #this runs when the class itself is loaded - it automatically calls the column_names method 
    attr_accessor col_name.to_sym #(which returns an array) and creates an attr_accessor for each element in the array - .to_sym (this converts string into a symbol)
  end

  def initialize(options={}) #always initialies with a hash 
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save #save is abstracted into multiple methods - to call upon table/column names and the values.
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0] #sets the id to the return of the last insert row id - table name is found via abstraction (calling a method)
  end

  def table_name_for_insert #since save is a instance method typcailly - this method has to first call upon itself (the instance) 
    self.class.table_name #then find it's class (Song) - then call upon the method of "table_name" - which returns the table name as a string 
  end

  def values_for_insert 
    values = [] #set up a array so that we can push all the column items into it
    self.class.column_names.each do |col_name| #like the table_name_for_insert method - this works with instance classes - to call upon itself.class.column_names - which is a class method.
      values << "'#{send(col_name)}'" unless send(col_name).nil? #after calling column_names class (which returns an array) - this will shovel in the value of each variable to the values array if it is not nil
    end #this uses an abstraction by invoking the send method - it calls self(instance).send(col_name) - which calls self.id (for first column) which returns a value - this works because of the previous attr_accessor setup
    values.join(", ") #since sql requires a string - this converts the values array with all the elements into an string seperated by comma.
  end

  def col_names_for_insert # like the previous two methods - this is an instance method so self.class is required to call the class method of column_names
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") #we call delete_if method on the return value because we do not want to save the value of "id" as SQL creates an ID upon inserting a new row.
  end #lastely - we join the array - into a string comma seperated

  def self.find_by_name(name) 
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'" #abstracts locating a row in the table by the item inputed - this calls the table_name class method to return the table songs
    DB[:conn].execute(sql) # this would also work with "SELECT * FROM #{self.table_name} WHERE name = ?" DB[:conn].execute(sql, name)
  end

end



