ActiveRecord::Migration.verbose = false

migration_path = File.expand_path('../../rails_app/db/migrate/', __FILE__)
# https://github.com/plataformatec/devise/blob/master/test/orm/active_record.rb
# Run any available migration
if Rails.version.start_with? '6'
  ActiveRecord::MigrationContext.new(migration_path, ActiveRecord::SchemaMigration).migrate
elsif Rails.version.start_with? '5.2'
  ActiveRecord::MigrationContext.new(migration_path).migrate
else
  ActiveRecord::Migrator.migrate(migration_path)
end
