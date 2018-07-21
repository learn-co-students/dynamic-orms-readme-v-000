require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    # query the table for the names of its columns
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    # get rid of any nil values
    column_names.compact
  end

  # metaprogramming attribute accessors
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    # iterate over the options hash
    options.each do |property, value|
      # use the #send method to interpolate the name of each hash key as a method
      # that we set equal to that key's value
      # as long as each property has a corresponding attr_accessor, this
      # #initialize method will work
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  # a class method inside an instance method
  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    # iterate over the column names stored in #column_names and use #send method
    # with each individual column name to invoke the method by that same name
    # and capture the return value
    self.class.column_names.each do |col_name|
      # wrap the return value in a string,
      # each value will be enclodes in single quotes because SQL expects us to
      # pass in each column value in single quotes
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    # since SQL handles the creation of an ID for a given table row,
    # when we save the object, we should not include the id column name
    # or insert a value for the id column

    # also, make the returned column names into a comma separated list,
    # contained in a string
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
