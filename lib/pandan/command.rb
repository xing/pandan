require 'claide'
require 'pandan/version'

module Pandan
  class Command < CLAide::Command
    require 'pandan/command/query'
    require 'pandan/command/targets'
    require 'pandan/command/dependency_graph'

    self.abstract_command = true
    self.command = 'pandan'
    self.version = Pandan::VERSION
    self.description = <<-DESC
      Retrieve Xcode dependency information with ease.
    DESC

  end
end
