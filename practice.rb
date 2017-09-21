class Practice_dyn_orm

    def self.table_name
      self.to_s.downcase.pluralize
    end

    def col_names
        db[:conn].results_as_hash = true

        sql = pragma table_info("#{tablename}")
        table_info = DB[:conn].execute(sql)

        col_names = []
        table_info.each do |col|
            col_names << col["name"]
        end

        col_names.compact (gets rid of nils)

        the output will be [id, name, age] as strings
    end

    to create attr_acc.

    col_names.each do |col_name|
        attr_accessor col_name.to_sym
    end

    create initialize with a send method

    def initialize(options={}) push in a hash or set to an empty hash use string interp to define the attrs
        options.each do |k,v|
            self.send("#{k}=", v)
        end
    end

    extract out methods to give the data for the rest of the program

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.col_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = []

        col names will leave me with ["id","name","age"]

        self.class.col_names.each do |col|
            values << "'#{send(col)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = SQL "INSERT INTO #{"table_name"} ("#{col_names_for_insert}") VALUES #{vals_for_insert}" SQL

        DB[:conn].execute(sql)

        do the id thing
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
        end
    end
end