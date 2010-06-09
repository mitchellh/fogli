require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fogli"
    gem.summary = "An efficient, simple, and intuitive Facebook Open Graph library."
    gem.description = "An efficient, simple, and intuitive Facebook Open Graph library."
    gem.email = "mitchell.hashimoto@gmail.com"
    gem.homepage = "http://github.com/mitchellh/fogli"
    gem.authors = ["Mitchell Hashimoto"]

    gem.add_dependency('rest-client', "~> 1.5.1")
    gem.add_dependency('json_pure', "~> 1.2.0")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "libs"
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--main', 'README.md', '--markup', 'markdown']
    t.options += ['--title', 'Fogli Documentation']
  end
rescue LoadError
  puts "Yard not available. Install it with: gem install yard bluecloth"
end
