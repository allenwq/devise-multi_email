ActiveRecord::Migration.verbose = false

migration_path = File.expand_path('../../rails_app/db/migrate/', __FILE__)
if ActiveRecord.version.release < Gem::Version.new('5.2.0')
  ActiveRecord::Migrator.migrate(migration_path)
else
  ActiveRecord::MigrationContext.new(migration_path).migrate
end
