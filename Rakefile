#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:test) do |spec|
  spec.rspec_opts = "-bc"
end
