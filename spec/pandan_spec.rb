require "spec_helper"

RSpec.describe Pandan do
  it "has a version number" do
    expect(Pandan::VERSION).not_to be nil
  end

  it "graph resolves dependencies correctly" do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets()
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = ['SampleFrameworkC', 'SampleFrameworkD', 'SampleFrameworkE']
      expect(dependencies.map &:name).to match_array expected_dependencies
    end
  end

  it "graph resolves dependencies correctly for single project" do
    use_fixture('xcworkspace_with_single_project') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets()
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = ['SampleFrameworkC', 'SampleFrameworkD', 'SampleFrameworkE']
      expect(dependencies.map &:name).to match_array expected_dependencies
    end
  end

  it "graph resolves inverse dependencies correctly" do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets()
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = ['SampleApp', 'SampleFrameworkBTests']
      expect(dependencies.map &:name).to match_array expected_dependencies
    end
  end

  it "parser excludes terms correctly" do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', '^((?!Tests).)*$')
      targets = parser.all_targets()
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = ['SampleApp']
      expect(dependencies.map &:name).to match_array expected_dependencies
    end
  end

  it "graph detects dependency cycle" do
    use_fixture('xcworkspace_with_dependency_cycle') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', '^((?!Tests).)*$')
      targets = parser.all_targets()
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      expect {
        graph.resolve_dependencies('SampleFrameworkB')
      }.to raise_error "Found dependency cycle: SampleFrameworkC -> SampleFrameworkB"
    end
  end

  it "graph works with CocoaPods generated workspace" do
    use_fixture('xcworkspace_generated_by_cocoapods') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets()
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('XNGAPIClient')
      expected_dependencies = ["AFNetworking", "CoreGraphics", "Foundation", "MobileCoreServices",
        "SAMKeychain", "Security", "SystemConfiguration", "UIKit", "XNGOAuth1Client"]
      expect(dependencies.map &:name).to match_array expected_dependencies
    end
  end
end
