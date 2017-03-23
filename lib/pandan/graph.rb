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
        self.neighbors << node
      end
    end

    attr_accessor :nodes, :reverse

    def initialize(reverse)
      @nodes = Hash.new
      @reverse = reverse
    end

    def add_target_info(targets)
      targets.each do |target|
        linked_libraries = find_linked_libraries(target)
        node = nodes[target.display_name]
        if node.nil?
          node = Node.new(target.display_name)
          nodes[target.display_name] = node
        end
        linked_libraries.each do |library_name|
          library_node = nodes[library_name]
          if library_node.nil?
            library_node = Node.new(library_name)
            nodes[library_name] = library_node
          end
          if reverse
            library_node.add_neighbor(node)
          else
            node.add_neighbor(library_node)
          end
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
    def find_linked_libraries(target)
      frameworks_build_phase = target.build_phases.find { |build_phase| build_phase.isa.eql? 'PBXFrameworksBuildPhase' }
      frameworks_build_phase.files.map { |file| file.display_name.gsub '.framework', '' }
    end

    def resolve(node, resolved, resolving = [])
      resolving << node
      node.neighbors.each do |neighbor|
        if not resolved.include? neighbor
          raise "Found dependency cycle: #{node.name} -> #{neighbor.name}" if resolving.include? neighbor
          resolve(neighbor, resolved, resolving)
        end
      end
      resolved << node
      resolving.delete(node)
    end
  end
end
