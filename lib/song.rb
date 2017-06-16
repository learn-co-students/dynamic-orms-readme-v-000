require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

  #CLASS METHODS

  # sets table name = songs
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    #query a table for column names
    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact #Returns a copy of column_names arr with all "nil" removed
  end

  #create attr_accessor with each column name as a :symbol
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  # search databse for specific name 
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end


  #INSTANCE METHODS

  # options default to empty hash {}
  # expect #new will be called with a hash argument -> Song.new({sample_hash})
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  # To access #table_name, a class method
  def table_name_for_insert
    self.class.table_name
  end

  # To access #column_names, a class method
  # remove id , since SQL3 gem handles ID creation when we INSERT row into DB
  # lastly, we need to transform arr into str with #join
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  # To access values of each column, using #column_names, a class method
  # evoke each column_name with #send method, ignore nil (e.g. id: nil)
  # push 'value' into [], e.g. ('Hello')
  # lastly, we need to transform arr into str with #join
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  # combine the 3 methods above into #save
  # e.g. INSERT INTO songs (name, album) VALUES ('Hello', '25')
  # finally, grab id from DB and set it for song instance
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end
