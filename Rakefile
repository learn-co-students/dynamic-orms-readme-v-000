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

  task :column_name do
    DB[:conn].result_as_has = true

    sql = "PRAGMA table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_name = []

    table_info.each do|column|
      column_name << column["name"]
    end

    column_name.compact
  end
