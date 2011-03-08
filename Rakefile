require 'rubygems'
require 'rake'

begin
  gem 'ore-tasks', '~> 0.5.0'
  require 'ore/tasks'

  Ore::Tasks.new
rescue LoadError => e
  STDERR.puts e.message
  STDERR.puts "Run `gem install ore-tasks` to install 'ore/tasks'."
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.title = "unified2"
  rdoc.rdoc_files.include("README.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

begin
  gem 'rspec', '~> 2.4.0'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end
task :default => :spec
