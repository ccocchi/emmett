module Emmett
  class Converter

    class Leaf
      def initialize(filename)
        @filename = filename
      end
    end

    class Node
      def initialize(name, children)
        @name = name
        @children = children
      end
    end

    class Group < Node
    end

    def self.tree=(val)
      @tree = val
    end

    def self.tree
      @tree
    end

    def initialize(config)
      @config       = config
      @content_dir  = @config.content_dir
      @files        = @config.content

      build_tree if @config.changed?
    end

    private

    def build_tree
      puts "Building tree.."
      self.class.tree = @files.map do |f|
        if f.is_a?(String)
          Leaf.new(f)
        elsif f['type'] == 'directory'
          traverse_directory(f['name'], group: true)
        end
      end
    end

    def traverse_directory(dir, group: nil)
      children = Dir.each_child(dir).map do |filename|
        if File.directory?(filename)
          traverse_directory(filename)
        else
          Leaf.new(filename)
        end
      end

      (group ? Group : Node).new(dir, children)
    end
  end
end