# encoding: utf-8

namespace :metrics do
  allowed_versions = %w(mri-1.9.3 mri-2.0.0 mri-2.1.0 mri-2.1.1 rbx-1.9.3)

  enabled = begin
    require 'mutant'
  rescue LoadError, NotImplementedError
    false
  end

  config    = Devtools.project.mutant
  enabled &&= config.enabled? && allowed_versions.include?(Devtools.rvm)

  if enabled && !ENV['DEVTOOLS_SELF']
    desc 'Measure mutation coverage'
    task mutant: :coverage do
      namespace =
        if config.zombify
          Mutant.zombify
          Zombie::Mutant
        else
          Mutant
        end

      namespaces = Array(config.namespace).map { |n| "::#{n}*" }

      ignore_subjects = config.ignore_subjects.flat_map do |matcher|
        %W[--ignore #{matcher}]
      end

      arguments  = %W[
        --include lib
        --require #{config.name}
        --score #{config.expect_coverage}
        --use #{config.strategy}
      ].concat(ignore_subjects).concat(namespaces)

      status = namespace::CLI.run(arguments)
      if status.nonzero?
        Devtools.notify_metric_violation 'Mutant task is not successful'
      end
    end
  else
    desc 'Measure mutation coverage'
    task mutant: :coverage do
      $stderr.puts 'Mutant is disabled'
    end
  end
end
