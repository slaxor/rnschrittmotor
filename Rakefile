require 'rubygems'
require 'rake'
require 'rake/testtask'

desc 'Default Task'
task :default => [ :test ]

desc 'Run the unit tests'
Rake::TestTask.new { |t|
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = false
}


