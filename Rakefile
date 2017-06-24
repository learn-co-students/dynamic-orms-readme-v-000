require_relative './config/environment'

	def reload!
		load_all './lib'
	end

	task :console do
	  Pry.start
	end

  task :table_name do
    self.to_s.downcase.pluralize
  end
  ### The `#table_name` Method#returns the name of a table,

  task :column_name do
    DB[:conn].result_as_has = true#says: when a `SELECT` statement
    #is executed, don't return a database
    #row as an array, return it as a hash with
    #the column names as keys.

    sql = "PRAGMA table_info('#{table_name}')"
    #query a table for the names of its columns?

    table_info = DB[:conn].execute(sql)
    column_name = []

    table_info.each do|column| #iterate over
      column_name << column["name"]
    end
    #the resulting
    #array of hashes to
    #collect *just the name of each column*
    column_name.compact
    #get rid of any `nil` values
    #that may end up in our collection
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
#iterate over the column names stored in the `column_names`
#class method and set an `attr_accessor` for each one,
#making sure to convert the column name string into a symbol with
#the `#to_sym` method, since `attr_accessor`s must be
#named with symbols

  ### The `#initialize` Method

  task :initialize do
      :initialize(options={})
      options.each do |property, value|
        self.send("#{property}=", value)
        #`#send` method to interpolate the name
        #of each hash key as a method that we set equal
        #to that key's value.
      end
  end
  #to give us the table name
  #associated to any given class:
  #`<class name>.table_name`
  def some_instance_method
    self.class.some_class_method
  end
  #**`#table_name_for_insert`**:
  def table_name_for_insert
    self.class.table_name
  end
  #for grabbing
  #the column names of the table associated with a given class:
  **`#col_names_for_insert`**:
  #turn them into a comma separated list, contained in a string
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  #### Abstracting the Values to Insert
  values = []
  self.class.column_names.each do |col_name|
    #how to programmatically invoke a method, without
    #knowing the exact name of the method, using the `#send` method.
    values << "'#{send(col_name)}'" unless send(col_name).nil?
    ##send` method with each individual column name
    #to invoke the method by that same name and
    #capture the return value:
  end

**`#values_for_insert`:**

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")#need comma separated values for our SQL statement
  end

#'s wrap up this code in a handy method, **`#values_for_insert`:**
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

#The `#save` Method:
def save
  sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

  DB[:conn].execute(sql)

  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = #{name}"
  DB[:conn].execute(sql)
end
