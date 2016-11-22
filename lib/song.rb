require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class Song

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
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
    self.class.table_name
    binding.pry
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)

  end

end  
      




#   def self.table_name
#     self.to_s.downcase.pluralize
#   end

#   def self.column_names
#     DB[:conn].results_as_hash = true

#     sql = "pragma table_info('#{table_name}')"

#     table_info = DB[:conn].execute(sql)
#     column_names = []
#     table_info.each do |row|
#       column_names << row["name"]
#       binding.pry
#     end
#     column_names.compact
#   end

#   self.column_names.each do |col_name|
#     attr_accessor col_name.to_sym
#   end

#   def initialize(options={})
#     options.each do |property, value|
#       self.send("#{property}=", value)
#     end
#   end
  
#   #create attr_accessors using meta

#   # def self.table_name

#   # end

#   # def self.column_names

#   # end
  
#   # self.column_names.each do |col_name|
#   #   att_accessor col_name.to_sym
#   # end

# def initialize(options={})
#   options.each do |property, value|
#     self.send("#{property}=", value)
#   end
# end    

#   #saving records dynamically
#   In order to write a method that can INSERT any record to any table we need to be able to craft the above SQL statement without explicitly referencing the songs table or column names and without explicitly referencing the values of a given Song instance.

#   to get the table, or class name as it were, do the following:
  
#   def some_instance_method
#     self.class.some_class_method
#   end
  
#   def table_name_for_insert
#     self.class.table_name
#   end  

#   #abstracting column names

#   self.class.column_names
#   --this will return an array like this:
#     ["id", "name", "album"] but we don't' save the id column name. We need to delete it. 
 
#   self.class.column_names.delete_if {|col| == 'id' }
#   --This will return:

#   ["name", "album"]

#   --turn the array into a comman separated list, contained in a string

#   self.class.column_names.delete_if {|col| col == "id"}.join(", ")

#   this will return: "name, album"

# final code to insert data into a column 

#   def col_names_for_insert
#     self.class.column_names.delete_if {|col| col == "id"}.joiun(", ")
#   end        
  

# how to grab the values in the column names, or rows, as it were
# Let's iterate over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:'

#   values = []

#   self.class.column_names.each do |col_name|
#     values << "'#{send(col_name)}'" unless send(col_name).nil?
#   end
  
#   --will return:
#   ["'the name of the song'", "'the album of the song'"]

#   convert to a string:
#   ["'the name of the song'", "'the album of the song'"].values.join(", ")   (values.join(", "))

#   method to insetr methods

#   def self.values_for_insert
#     values = []
#     self.class.column.names.each do |col_name|
#       values << "'#{send(col_name)}'" unless send(col_name).nil?
#     end
#     values.join(", ")   
#   end
  
#   --now put it all together in a save method 

#   def save
#     sql = "INSERT INFO #{table_name_for_insertle} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

#     DB{:conn].execute(sql)  

#     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM 
#       #{table_name_for_insert}")[0][0]

#   end      

#   find_by_name dynamically

#   def self.find_by_name(name)
#     sql = "SELECT * FROM #{self.table_name} WHERE name = #{name}"
#     DB[:conn].execute(sql)
#   end