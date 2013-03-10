require "bundler"
Bundler.setup

require 'active_record'
require 'logger'

task :environment do
  dbconfig = YAML::load(File.open 'config/database.yml')
  ActiveRecord::Base.establish_connection(dbconfig)
end


namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
    Rake::Task["db:schema:dump"].invoke
  end
  
  namespace :migrate do
    desc 'Runs the "down" for a given migration VERSION'
    task(:down => :environment) do
      ActiveRecord::Migrator.down('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      Rake::Task["db:schema:dump"].invoke
    end

    desc 'Runs the "up" for a given migration VERSION'
    task(:up => :environment) do
      ActiveRecord::Migrator.up('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      Rake::Task["db:schema:dump"].invoke
    end

    desc "Rollbacks the database one migration and re migrate up"
    task(:redo => :environment) do
      ActiveRecord::Migrator.rollback('db/migrate', 1 )
      ActiveRecord::Migrator.up('db/migrate', nil )
      Rake::Task["db:schema:dump"].invoke
    end
  end
  
  namespace :schema do
    task :dump => :environment do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || "db/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end