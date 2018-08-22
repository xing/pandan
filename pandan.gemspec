# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pandan/version'

Gem::Specification.new do |spec|
  spec.name          = 'pandan'
  spec.version       = Pandan::VERSION
  spec.authors       = ['Renzo Crisóstomo', 'Kim Dung-Pham', 'Max Friedrich']
  spec.email         = ['renzo.crisostomo@xing.com', 'kim.dung-pham@xing.com', 'max.friedrich@xing.com']
  spec.summary       = 'Retrieve Xcode dependency information with ease.'
  spec.description   = 'CLI tool that outputs dependency information from a set of Xcode projects with targets that'\
                       'depend on each other, it does it by creating a (reverse) dependency graph and doing a'\
                       'breadth-first search.'
  spec.homepage = 'https://github.com/xing/pandan'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = 'pandan'
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'claide', '~> 1.0.0'
  spec.add_runtime_dependency 'ruby-graphviz', '~> 1.2'
  spec.add_runtime_dependency 'xcodeproj', '~> 1.6.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter'
end
