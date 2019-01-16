# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pandan do
  it 'has a version number' do
    expect(Pandan::VERSION).not_to be nil
  end

  it 'graph resolves dependencies correctly' do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = %w[SampleFrameworkC SampleFrameworkD SampleFrameworkE]
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end

  it 'graph resolves dependencies correctly for single project' do
    use_fixture('xcworkspace_with_single_project') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = %w[SampleFrameworkC SampleFrameworkD SampleFrameworkE]
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end

  it 'graph resolves inverse dependencies correctly' do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = %w[SampleApp SampleAppTests SampleFrameworkBTests]
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end

  it 'parser excludes terms correctly' do
    use_fixture('xcworkspace_with_correct_dependency_graph') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', '^((?!Tests).)*$')
      targets = parser.all_targets
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('SampleFrameworkB')
      expected_dependencies = ['SampleApp']
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end

  it 'graph detects dependency cycle' do
    use_fixture('xcworkspace_with_dependency_cycle') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', '^((?!Tests).)*$')
      targets = parser.all_targets
      graph = Pandan::Graph.new(true)
      graph.add_target_info(targets)
      expect do
        graph.resolve_dependencies('SampleFrameworkB')
      end.to raise_error 'Found dependency cycle: SampleFrameworkC -> SampleFrameworkB'
    end
  end

  it 'graph works with CocoaPods generated workspace' do
    use_fixture('xcworkspace_generated_by_cocoapods') do
      parser = Pandan::Parser.new('SampleApp.xcworkspace', nil)
      targets = parser.all_targets
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      dependencies = graph.resolve_dependencies('XNGAPIClient')
      expected_dependencies = %w[AFNetworking CoreGraphics Foundation MobileCoreServices
                                 SAMKeychain Security SystemConfiguration UIKit XNGOAuth1Client]
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end

  it 'graph works with dependencies defined using build settings' do
    use_fixture('xcworkspace_using_only_build_settings') do
      parser = Pandan::Parser.new('Sample.xcworkspace', nil)
      targets = parser.all_targets
      ld_flags_info = parser.other_linker_flags
      graph = Pandan::Graph.new(false)
      graph.add_target_info(targets)
      graph.add_other_ld_flags_info(ld_flags_info)
      dependencies = graph.resolve_dependencies('Sample')
      expected_dependencies = %w[Baka GoogleMobileAds]
      expect(dependencies.map(&:name)).to match_array expected_dependencies
    end
  end
end
