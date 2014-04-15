# encoding: utf-8

require 'rubocop/rake_task'

namespace :metrics do
  desc 'Check with code style guide'
  Rubocop::RakeTask.new(:rubocop) do |task|
    config = Devtools.project.rubocop
    task.options = %W[--config #{config.config_file.to_s}]
  end
end
