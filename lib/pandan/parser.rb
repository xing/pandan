require 'xcodeproj'

module Pandan
  class Parser
    attr_reader :workspace, :regex

    def initialize(workspace_path, filter)
      @workspace_dir = File.dirname(workspace_path)
      @workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
      @regex = filter
      @regex ||= '.*' # Match everything
    end

    def all_targets
      all_project_paths = workspace.file_references.map(&:path)
      projects = all_project_paths.map do |project_path|
        Xcodeproj::Project.open(File.expand_path(project_path, @workspace_dir))
      end
      projects.flat_map(&:targets).select { |target| target.name =~ /#{regex}/ }
    end
  end
end
