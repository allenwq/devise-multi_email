ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.include_root_in_json = true

ActiveRecord::Migrator.migrate(File.expand_path('../../rails_app/db/migrate/', __FILE__))
