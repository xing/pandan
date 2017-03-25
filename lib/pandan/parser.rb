require 'xcodeproj'

module Pandan
  class Parser
    attr_reader :workspace, :regex

    def initialize(workspace_path, filter)
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
      @regex = filter
      @regex ||= '.*' # Match everything
    end

    def all_targets
      all_project_paths = workspace.file_references.map(&:path)
      projects = all_project_paths.map { |project_path| Xcodeproj::Project.open(project_path) }
      projects.flat_map(&:targets).select { |target| target.name =~ /#{regex}/ }
    end
  end
end
