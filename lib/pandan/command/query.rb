require 'pandan/command'
require 'pandan/parser'
require 'pandan/graph'
require 'pandan/xcworkspace'

module Pandan
  class Query < Command
    self.arguments = [
      CLAide::Argument.new('target', true)
    ]

    def self.options
      [
        ['--xcworkspace=path/to/workspace', 'If not set, Pandan will try to find a workspace'],
        ['--reverse', 'If set, pandan will output the targets that depend on the argument'],
        ['--comma-separated', 'If set, Pandan outputs a comma-separated list instead of multiple lines'],
        ['--filter=expression', 'If set, pandan will select all targets whose name match the regular expression']
      ].concat(super)
    end

    self.summary = <<-DESC
      Retrieve Xcode dependency information from the target passed as an argument
    DESC

    def initialize(argv)
      @target = argv.shift_argument
      @xcworkspace = argv.option('xcworkspace')
      @xcworkspace ||= XCWorkspace.find_workspace
      @reverse = argv.flag?('reverse')
      @comma_separated = argv.flag?('comma-separated')
      @filter = argv.option('filter')
      super
    end

    def validate!
      super
      if @target.nil?
        help! 'A target is required to retrieve the dependency information'
      end
      if @xcworkspace.nil?
        help! 'Could not find the workspace. Try setting it manually using the --xcworkspace option.'
      end
    end

    def run
      parser = Parser.new(@xcworkspace, @filter)
      targets = parser.all_targets
      graph = Graph.new(@reverse)
      graph.add_target_info(targets)
      deps = graph.resolve_dependencies(@target).map &:name
      unless @filter.nil?
        deps.select! do |dep|
          dep.name.include? @filter
        end
      end

      if @comma_separated
        puts deps.join ','
      else
        puts deps
      end
    end
  end
end
