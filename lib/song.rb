require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize        # #pluralize is from inflector lib.. otherwise use "#{data}s"
  end

  def self.column_names
    DB[:conn].results_as_hash = true      # PRAGMA http://www.tutorialspoint.com/sqlite/sqlite_pragma.htm

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []                   #make an array
    table_info.each do |row|            # iterate over db[:conn].execute(///table infot////)
      column_names << row["name"]       # push  to array
    end
    column_names.compact                # return array   //// .compact gets rid of nil values////
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym       #creates attr_accessor based on columb names
  end

  def initialize(options={})            # ///// MEMORIZE THIS /////
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
    self.class.table_name         # instance method so you need to get .class from the instance /// self ///
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?    # id is nil until THE DATABASE gives it a value
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")  #DON'T INSERT ID /// DATABASE DOES THAT
  end                                                                 # I prefer key[1..-1].collect when possible

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"   
    DB[:conn].execute(sql)
  end

end
