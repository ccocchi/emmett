require "emmett/visitors/core"
require "emmett/visitors/reader"
require "emmett/visitors/normalizer"
require "emmett/visitors/menu_output"
require "emmett/visitors/content_output"

module Emmett
  class Tree
    class << self
      # Internal representation of our tree
      @tree = nil

      def tree=(val)
        @tree = val
      end

      def tree
        @tree
      end
    end

    def initialize(config)
      @config       = config
      @content_dir  = @config.content_dir
      @files        = @config.content
      @timestamp    = File.mtime(@content_dir)

      build_tree
    end

    def refresh
      if @config.changed?
        @files = @config.content
        build_tree
      elsif File.mtime(@content_dir) > @timestamp
        build_tree
      end

      # Refresh each leaf's content if it was updated
      self.class.tree.accept(Visitors::Reader.new)

      # TODO: normalizing each time is overkill but we need to ensure that updated
      # leafs correctly impact its parent resource
      self.class.tree.accept(Visitors::Normalizer.new)
    end

    def menu_output
      self.class.tree.accept(Visitors::MenuOutput.new)
    end

    def output
      self.class.tree.accept(Visitors::ContentOutput.new)
    end

    def pretty_print
      require 'emmett/printer'
      visitor = Printer.new
      self.class.tree.each { |n| n.accept(visitor) }
    end

    private

    def build_tree
      children = @files.map do |f|
        if f.is_a?(String)
          Nodes::Leaf.new(File.join(@content_dir, "#{f}.md"), f)
        else
          dir = File.join(@content_dir, f["name"])
          traverse_directory(dir, name: f["name"], type: f["type"])
        end
      end

      self.class.tree = Nodes::Root.new(children)
    end

    def traverse_directory(dir, name:, type:)
      children = Dir.each_child(dir).sort.map! do |filename|
        path  = File.join(dir, filename)

        if File.directory?(path)
          traverse_directory(path, name: filename, type: determine_type_from_current(type))
        else
          Nodes::Leaf.new(path, filename.slice(0..-4))
        end
      end

      class_from_type(type).new(dir, name, children)
    end

    # Manual constantize
    #
    def class_from_type(type)
      case type
      when "resources_group", "group" then Nodes::ResourcesGroup
      when "resource" then Nodes::Resource
      when "section" then Nodes::Section
      end
    end

    # Determine type of sub-directory based on the type of the current directory.
    # Structure will only be as follow: ResourceGroup -> Resource -> Section
    #
    def determine_type_from_current(type)
      case type
      when 'resources_group' then 'resource'
      when 'resource' then 'section'
      else
        raise Emmett::Error, 'directory nesting too deep'
      end
    end
  end
end
