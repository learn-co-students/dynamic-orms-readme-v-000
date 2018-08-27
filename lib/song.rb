require_relative "../config/environment.rb"
require 'active_support/inflector' #provides #pluralize used in #table_name

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
    column_names.compact #make sure there aren't any nil values among our table names 
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym #this is writing code for us 
  end

  def initialize(options={}) #takes in hash of keyword arguments, default is empty hash, new should be called on hash (from table)
    options.each do |property, value| #this is also writing code for us
      self.send("#{property}=", value)  #we're sending the setter method to our receiver; setter will change with the property name
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name #self would refer to instance, so class added to pop up one level to the class method
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil? #sending the getter for each column, returns attribute of that getter
    end
    values.join(", ") #puts returned values together in comma-separated list
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") #don't insert id into the table; that'll be handled by the db
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



