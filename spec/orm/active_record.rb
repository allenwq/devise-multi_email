ActiveRecord::Migration.verbose = false

ActiveRecord::Migrator.migrate(File.expand_path('../../rails_app/db/migrate/', __FILE__))
