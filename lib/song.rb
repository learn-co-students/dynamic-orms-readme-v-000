require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  # #2, build attr_accessors from column names:
  #takes the name of the class, referenced by self keyword,
  #and turns it into a string, downcases, and pluaralizes it to match convention
  #from the ACTIVE_SUPPORT/INFLECTOR library
  def self.table_name  
    self.to_s.downcase.pluralize
  end

  #to obtain column names we use the "PRAGMA table_info(<table name>)" which
  #thanks to #results_as_hash (config) gives us an array desc. the table
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #will create a hash for each column, we only need name from each

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row| #grabs the column name from each hash
      column_names << row["name"]
    end
    column_names.compact #gets rid of any nil values to be safe
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



