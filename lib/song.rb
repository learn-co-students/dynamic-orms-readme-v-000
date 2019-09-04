require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class Song


  def self.table_name
    self.to_s.downcase.pluralize
    # Note that the .pluralize method only works because we required reflector up top.
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact  # the .compact method removes any nil values from the list
  end

  self.column_names.each do |col_name|
    # We iterate over the array of column names provided by the .column_names method and assign them as attr_accessors (which are always symbols)
    attr_accessor col_name.to_sym
  end

#we pass a hash into the initialize method
#we iterate over each hash and use the send method to interpolate the name of each hash key as a method that we set equal to that key's value.
#Remember that our attr_accessors have already been creating at this point, we are just assignment the matched attr_accessors their values.
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

#The .table_name method gives us the table name associated with a given class
#Since the following method is an INSTANCE method, in order to access a class method, we need to use the .class keyword to tell our program that we are referencing a class method, not instance.
  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

#We need to remove id from the insert list, since the database table will automatically create an id for us.
#also, since this statement returns to us an array, we want to return a comma separated list instead.
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
