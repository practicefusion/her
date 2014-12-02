require "bundler"
require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => :spec

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.pattern = "spec/**/*_spec.rb"
end

# don't push to rubygems when running 'rake release'
ENV['gem_push'] = 'no'

# add push to our private gem server here, since we are no longer pushing to rubygems
Rake::Task["release"].enhance do
  spec = Gem::Specification::load(Dir.glob("*.gemspec").first)
  sh "gem push pkg/#{spec.name}-#{spec.version}.gem --host http://gems.hq.practicefusion.com"
end
