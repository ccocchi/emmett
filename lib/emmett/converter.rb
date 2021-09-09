require 'emmett/reader'

module Emmett
  class Converter

    module Visitable
      def accept(visitor)
        visitor.visit(self)
      end
    end

    module Anchorable
      def anchor(content, class_list: nil)
        %(<a href="##{anchor_id}") <<
          (class_list ? %( class="#{class_list}") : '') <<
          "><span>#{content}</span></a>"
      end
    end

    class Leaf
      include Visitable
      include Anchorable

      attr_reader :filename
      attr_accessor :metadata, :content, :example, :ts

      def initialize(filename)
        @filename = filename
      end
    end

    class Node
      include Visitable
      include Anchorable

      attr_reader :name, :path, :children
      attr_accessor :ts

      def initialize(path, children)
        @path = path
        @children = children
      end
    end

    class ResourcesGroup < Node; end
    class Resource < Node; end
    class Section < Node; end

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

    def read_markdown
      visitor = Reader.new
      byebug
      # self.class.tree.each { |n| n.accept(visitor) }
    end

    def pretty_print
      require 'emmett/printer'
      visitor = Printer.new
      self.class.tree.each { |n| n.accept(visitor) }
    end

    private

    def build_tree
      self.class.tree = @files.map do |f|
        if f.is_a?(String)
          Leaf.new(File.join(@content_dir, "#{f}.md"))
        else
          dir = File.join(@content_dir, f['name'])
          traverse_directory(dir, type: f['type'])
        end
      end
    end

    def traverse_directory(dir, type:)
      children = Dir.each_child(dir).map do |filename|
        path = File.join(dir, filename)

        if File.directory?(path)
          traverse_directory(path, type: determine_type_from_current(type))
        else
          Leaf.new(path)
        end
      end

      class_from_type(type).new(dir, children)
    end

    def class_from_type(type)
      case type
      when "resources_group" then ResourcesGroup
      when "resource" then Resource
      when "section" then Section
      end
    end

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