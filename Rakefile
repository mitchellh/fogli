require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fogli"
    gem.summary = "Facebook Open Graph Library"
    gem.description = "Facebook Open Graph Library"
    gem.email = "mitchell.hashimoto@gmail.com"
    gem.homepage = "http://github.com/mitchellh/fogli"
    gem.authors = ["Mitchell Hashimoto"]
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
