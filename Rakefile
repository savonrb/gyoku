require "bundler"
require "bundler/setup"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-c)
  t.ruby_opts = %w(-w)
end

task :default => :spec
task :test => :spec
