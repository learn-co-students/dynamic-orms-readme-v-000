require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql) #returns a hash of table info, including column names
    column_names = []
    table_info.each do |row|
      column_names << row["name"] #grabbing the value of the name key in hash (which is column names) and push it to column_names array
    end
    column_names.compact # remove any nil or blank values and return array
  end

  # create attr_accessor from each of the column names
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={}) # options is an empty hash
    options.each do |property, value|
      self.send("#{property}=", value) #interpolate each class property/set equal to key value
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #convert
  def table_name_for_insert
    self.class.table_name
  end

  #iterate over the column names stored and use the send methods
  # with indv column names to invoke the method by the same names
  #and capture the return value
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ") # join values array into a string separated by comma's
  end

# create comma separated list of column names for SQL insert statement
#  exclude id as this is auto-incremented when row is inserted into DB
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
