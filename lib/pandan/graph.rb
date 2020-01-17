# frozen_string_literal: true

require 'xcodeproj'
require 'pandan/xcodeproj/user_interface.rb'

module Pandan
  class Graph
    class Node
      attr_accessor :name
      attr_accessor :neighbors

      def initialize(name)
        self.name = name
        self.neighbors = []
      end

      def add_neighbor(node)
        neighbors << node
      end
    end

    attr_accessor :nodes, :reverse

    def initialize(reverse)
      @nodes = {}
      @reverse = reverse
    end

    def add_target_info(targets)
      targets.each do |target|
        linked_libraries = find_linked_libraries(target)
        node = node_for_target_display_name(target.display_name)
        linked_libraries.each do |library_name|
          library_node = node_for_target_display_name(library_name)
          add_neighbor(node, library_node)
        end
      end
    end

    def add_other_ld_flags_info(ld_flags_info)
      ld_flags_info.each do |target, ld_flags_per_config|
        node = node_for_target_display_name(target.display_name)
        ld_flags_per_config.each_value do |ld_flags|
          joined_flags = ld_flags.join(' ')
          joined_flags.match(/-l"(.*?)"/).captures.each { |library| add_as_neighbor(node, library) }
          joined_flags.match(/-framework "(.*?)"/).captures.each { |framework| add_as_neighbor(node, framework) }
        end
      end
    end

    def resolve_dependencies(target)
      resolved = []
      target_node = nodes[target]
      raise "Target #{target} not found" if target_node.nil?

      resolve(target_node, resolved)
      resolved.delete(target_node)
      resolved
    end

    private

    def add_as_neighbor(node, item)
      add_neighbor(node, node_for_target_display_name(item))
    end

    def node_for_target_display_name(display_name)
      node = nodes[display_name]
      if node.nil?
        node = Node.new(display_name)
        nodes[display_name] = node
      end
      node
    end

    def add_neighbor(source, destination)
      if reverse
        destination.add_neighbor(source)
      else
        source.add_neighbor(destination)
      end
    end

    def find_linked_libraries(target)
      frameworks_build_phase = target.build_phases.find { |build_phase| build_phase.isa.eql? 'PBXFrameworksBuildPhase' }

      return [] unless frameworks_build_phase

      frameworks_build_phase.files.map { |file| file.display_name.gsub '.framework', '' }
    end

    def resolve(node, resolved, resolving = [])
      resolving << node
      node.neighbors.each do |neighbor|
        next if resolved.include? neighbor
        raise "Found dependency cycle: #{node.name} -> #{neighbor.name}" if resolving.include? neighbor

        resolve(neighbor, resolved, resolving)
      end
      resolved << node
      resolving.delete(node)
    end
  end
end
