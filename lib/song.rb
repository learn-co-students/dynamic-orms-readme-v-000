require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  #our way of getting at the table name of whatever class we're in
  def self.table_name
    self.to_s.downcase.pluralize
  end

  #abstracting away discrete column names
  def self.column_names
    #we get a hash back from the db instead of array
    DB[:conn].results_as_hash = true
    #pragma tells us everything about the table, interpolate into this command the table_name method
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    #store in column_names the value of each hash with the key "name"
    table_info.each do |row|
      column_names << row["name"]
    end
    #make sure there are no nil values
    column_names.compact
  end

  #make an attr accessor for each column name
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  #define initialize to accept a hash
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #interpolate values into sql statements
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #bring class level method down to instance for use in insert
  def table_name_for_insert
    self.class.table_name
  end

  #format values for insert
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  #format colum names for insert/delete id(nil at first)
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
