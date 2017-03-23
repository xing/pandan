require 'pandan/command'
require 'pandan/parser'
require 'pandan/xcworkspace'

module Pandan
  class Targets < Command
    def self.options
      [
        ['--xcworkspace=path/to/workspace', 'If not set, Pandan will try to find a workspace'],
        ['--comma-separated', 'If set, Pandan outputs a comma-separated list instead of multiple lines'],
        ['--filter=expression', 'If set, pandan will select all targets whose name match the regular expression']
      ].concat(super)
    end

    self.summary = <<-DESC
      Retrieve all available targets of an Xcode workspace
    DESC

    def initialize(argv)
      @xcworkspace = argv.option('xcworkspace')
      @xcworkspace ||= XCWorkspace.find_workspace
      @comma_separated = argv.flag?('comma-separated')
      @filter = argv.option('filter')
      super
    end

    def validate!
      super
      if @xcworkspace.nil?
        help! 'Could not find the workspace. Try setting it manually using the --xcworkspace option.'
      end
    end

    def run
      parser = Parser.new(@xcworkspace, @filter)
      targets = parser.all_targets

      if @comma_separated
        puts targets.join ','
      else
        puts targets
      end
    end
  end
end
