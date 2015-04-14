require './lib/lt_base.rb'
require './lib/util/redis_server.rb'
require 'irb'
require 'term/ansicolor'
require 'open3'

module LT
  module Term class << self
    include ::Term::ANSIColor
  end; end
end

## AR 4: The following section allows us to run AR w/out Rails
# Overwrite the already existing Rake task "load_config"
class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

# Load the ActiveRecord tasks
spec = Gem::Specification.find_by_name("activerecord")
load File.join(spec.gem_dir, "lib", "active_record", "railties", "databases.rake")

# Overwrite the load config
Rake::Task["db:load_config"].overwrite do
  Rake::Task[:'lt:boot'].invoke
end

# AR Migrations need an environment with an already established database connection
task :environment => ["db:load_config"] do
end
## End AR 4 installation


desc 'Print all rake tasks'
task :default do
  system "rake --tasks"
end

task :full_tests do
  Rake::Task[:'lt:test:run_full_tests'].invoke
end

task :tests do
  Rake::Task[:'lt:test:run_tests'].invoke
end

task :console do
  Rake::Task[:'lt:console'].invoke
end


namespace :lt do
  namespace :webapp do
    desc "Boot WebApp environment"
    task :boot do
      Rake::Task[:'lt:boot'].invoke
    end
    desc "Run WebApp server - this starts the webserver"
    task :start do
      # TODO - set port/server from environment var
      run_cmd = "rackup -p 8080 -o localhost config.ru"
      $stdout.sync = true
      Kernel.system(run_cmd)
    end
    desc "Run WebApp server - this starts the webserver in dev mode with rerun"
    task :start_dev do
      # TODO - set port/server from environment var
      run_cmd = "rerun -- rackup -p 8080 -o localhost config.ru"
      $stdout.sync = true
      Kernel.system(run_cmd)
    end
  end # namespace :webapp

  namespace :janitors do
    desc "Process full workload from Redis to data tables"
    task :process_redis_messages => [:redis_to_raw_messages, :raw_messages_to_page_visits] do
      LT::logger.info("process_redis_analytics completed")
    end

    desc "Convert Redis queue to raw_messages table"
    task :redis_to_raw_messages do
      Rake::Task[:'lt:boot'].invoke
      require './lib/janitors/redis_postgres_extract.rb'
      LT::Janitors::RedisPostgresExtract.redis_to_raw_messages
    end
    desc "Convert raw_messages to page_views"
    task :raw_messages_to_page_visits do
      Rake::Task[:'lt:boot'].invoke
      require './lib/janitors/redis_postgres_extract.rb'
      LT::Janitors::RawMessagesExtract.raw_messages_to_page_visits
    end
    desc "Convert raw_messages to video_views"
    task :raw_messages_to_video_views do
      Rake::Task[:'lt:boot'].invoke
      require './lib/janitors/redis_postgres_extract.rb'
      LT::Janitors::RawMessagesExtract.raw_messages_to_video_visits
    end
    desc "Fill YouTube Information"
    task :fill_video_youtube_information do
      Rake::Task[:'lt:boot'].invoke
      require './lib/janitors/web_extractor.rb'
      LT::Janitors::WebExtractor.fill_youtube_info
    end

    desc "Extract Learning Registry data to raw documents table from http://sandbox.learningregistry.org"
    task :extract_meta_data do # TODO: rename this rake task name.
      Rake::Task[:'lt:boot'].invoke
      require './lib/janitors/learning_registry_extract.rb'
      LT::Janitors::LearningRegistryExtract.retrieve({'node' => 'http://sandbox.learningregistry.org'})
    end
  end # namespace :janitors

  namespace :utility do
    desc "Loads a single CSV file into the corresponding database table"
    task :load_file, [:csvfile] do |t,args|
      Rake::Task[:'lt:boot'].invoke
      require './lib/util/csv_database_loader.rb'
      LT::Utilities::CsvDatabaseLoader.load_file(args[:csvfile])
    end

    desc "Loads all CSV files within a path into the corresponding database tables"
    task :load_dir, [:csvpath] do |t,args|
      Rake::Task[:'lt:boot'].invoke
      require './lib/util/csv_database_loader.rb'
      LT::Utilities::CsvDatabaseLoader.load_directory(args[:csvpath])
    end
  end

  desc "Boot up a console with required context"
  task :console => [:boot] do
    IRB.setup nil
    IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
    require 'irb/ext/multi-irb'
    IRB.irb nil, self
  end

  desc "Boot up a console with alternative ruby interactive 'pry'"
  task :console_pry do
    Rake::Task[:'lt:boot'].invoke
    binding.pry
  end

  desc "Boot Core-app system"
  task :boot do
    LT::boot_all(File::dirname(__FILE__))
  end

  desc "Install all gems via bundle"
  task :bundle_install => [:'lt:boot'] do
    output = `bundle install`
    LT::logger.debug(output)
  end

  desc "Seed environment db with data (generally speaking, don't do this in testing env)"
  task :seed => [:'lt:boot', :'db:seed']

  namespace :test do
    desc "Run complete test suite include DB teardown/rebuild/reseed"
    task :run_full_tests => [:'lt:test:boot', :'db:full_reset'] do
      Rake::Task[:'lt:bundle_install'].invoke
      LT::logger.info("Test setup complete. Running all tests.")
      LT::run_tests
    end

    desc "Run complete test suite w/out DB reset"
    task :run_tests => [:'lt:test:boot',
      :'lt:test:db:migrate_tables'] do
      LT::run_tests
    end

    desc "Run single test file"
    task :run_test, [:testfile] => [:'lt:test:boot',
      :'lt:test:db:migrate_tables'] do |t, args|
      arg_filename = args[:testfile]
      # if we are given a file with no path, search test folder for the file to run
      if arg_filename == File::basename(arg_filename) then
        filename = Dir::glob("test/**/#{arg_filename}*").first
      else
        filename = arg_filename
      end
      LT::run_test(File::expand_path(filename), LT::test_path)
    end

    task :boot do
      # Force us into testing environment, then boot core-app
      ENV['RAILS_ENV'] = 'test'
      Rake::Task[:'lt:boot'].invoke
      LT::testing!
    end
    namespace :db do
      desc "Drop and recreate test db, run migrations"
      task :full_reset => [:'lt:boot', :drop_db, :create_db, :migrate_tables] do
        LT::logger.info("Performing full DB testing reset")
      end
      desc "Drop test db"
      task :drop_db do
        ## BUG: If DB can't be dropped, this command does not raise an exception
        ##      It only prints a screen warning which is easy to miss
        ## Rec: Raise exception if DB exists after dropping?
        LT::testing!
        LT::logger.info("Dropping testing DB")
        Rake::Task[:'db:drop'].invoke
      end
      task :create_db do
        LT::testing!
        LT::logger.info("Creating testing DB")
        Rake::Task[:'db:create'].invoke
      end
      task :migrate_tables do
        LT::testing!
        LT::logger.info("Migrating testing DB")
        Rake::Task[:'db:migrate'].invoke
      end
    end
    desc "Monitor files for changes and run a single test when a change is detected"
    task :monitor => [:'lt:test:boot', :'lt:test:db:migrate_tables'] do |t, args|
      keep_running = true
      last_test_file = nil
      test_file = ""
      puts "\n\n"
      dot = ['.', ' '].cycle
      while keep_running do
        # Loop until interrupted by ctrl-c
        trap("INT") { puts "\nExiting"; keep_running = false; exit;}
        # if ctrl-z is pressed, re-run the last test file
        trap("TSTP") {
          if !last_test_file.nil? then
            puts "\nRe-running last test: #{last_test_file}"
            test_file = last_test_file
          end
        }
        test_list = FileList['test/**/*_test.rb']
        orig_test_dates = {}
        test_list.each do |file|
          orig_test_dates[file] = File.stat(file).mtime
        end
        # loop through test_list looking for date changes
        keep_searching = true
        while keep_searching && keep_running do
          print "\r#{LT::Term::white}***#{LT::Term::reset} Waiting for file changes. (#{Time::now.strftime('%I:%M %p')}), ctrl-z: re-run last, ctrl-c: exit#{dot.next}"
          Kernel::sleep(0.3) # wait 3/10 second between searches for changed files
          test_list.each do |file|
            Kernel::sleep(0.05) # keep the cpu from maxing out
            if orig_test_dates[file] != File.stat(file).mtime
              print "\n",LT::Term::white,"  File change detected: ", LT::Term::bold,"./#{file}",LT::Term::reset,"\n"
              puts "  Time is: #{Time::now}"
              keep_searching = false
              test_file = file
            end
          end
          if !test_file.blank? && keep_running
            full_test_file = File::expand_path(File::join('.',test_file))
            # invoke the test b/c the file has changed
            puts "Running test suite..."
            last_test_file = test_file
            # we capture the output
            output = `rake lt:test:run_test[#{full_test_file}]`
            output.each_line do |result_line|
              failure_error = result_line.match(/^\s+[0-9]+\) Error:/) || result_line.match(/^\s+[0-9]+\) Failure:/)
              asserts_failed = result_line.match(/runs, ([0-9]+) assertions, ([0-9]+) failures, ([0-9]+) errors/)
              if failure_error then
                puts LT::Term::red+result_line+LT::Term::reset+LT::Term::yellow
              elsif asserts_failed
                asserts = asserts_failed[1]
                failures = asserts_failed[2]
                errors = asserts_failed[3]
                if failures == "0" && errors == "0" then
                  puts LT::Term::reset+LT::Term::green+result_line+LT::Term::reset
                else
                  puts LT::Term::reset+LT::Term::red+result_line
                end
              else
                puts result_line
              end
            end
            print LT::Term::reset
            test_file = ""
          end
        end # while keep_searching... -- change detection loop
      end # while keep_running do -- main loop
    end # task :monitor
  end # test namesapce
end # lt namespace

namespace :build do
  # Cruise Control will call this task if it exists
  task :core_app do
    puts "Building core-app project..."
    puts "Running in dir: #{Dir::pwd}"
    puts "Running `sudo bundle install`"
    puts `sudo bundle install`
    puts "Running `sudo bundle update`"
    puts `sudo bundle update`
    Rake::Task["full_tests"].invoke
  end
end
