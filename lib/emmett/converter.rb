require "emmett/visitors/core"
require "emmett/visitors/reader"
require "emmett/normalizer"

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

      def name
        @name ||= @filename.slice(0, -4)
      end

      def menu_output
        "<li>#{anchor(menu_title)}</li>"
      end

      def has_signature?
        method && path
      end

      def signature
        anchor(sig)
      end

      def set_identifier(parent_resource = nil)
        _id = metadata&.[]("id") || name
        @id = parent_resource ? "#{parent_resource}-#{_id}" : _id
      end

      private

      def anchor_id
        @id
      end

      def sig
        @sig ||= <<~HTML
          <div class="endpoint-def">
            <div class="method method__#{method.downcase}">#{method.upcase}</div>
            <div class="path">#{path}</div>
          </div>
        HTML
      end

      def menu_title
        @metadata['menu_title']
      end

      def method
        @metadata['method']
      end

      def path
        @metadata['path']
      end
    end

    class Node
      include Visitable
      include Anchorable

      attr_reader :name, :path, :children
      attr_accessor :ts, :desc_node, :object_node, :children

      def initialize(path, children)
        @path = path
        @children = children
      end

      def output
        children.map(&:output).join
      end
    end

    class ResourcesGroup < Node
      def menu_output
        title = "<h5 class=\"nav-group-title\">#{name}</h5>" if name && name.length > 0

        <<-HTML
          <div class="sidebar-nav-group">
            #{title}
            <ul>#{children.map(&:menu_output).join}</ul>
          </div>
        HTML
      end
    end

    class Resource < Node
      def output

      end

      def menu_output
        head, *tail = children

        <<-HTML
          <li data-anchor="#{clean_name}">
            #{head.anchor(clean_name, class_list: 'expandable')}
            <ul>#{tail.map(&:menu_output).join}</ul>
          </li>
        HTML
      end

      private

      def clean_name
        @clean_name ||= name.tr('_', ' ').split.map!(&:capitalize).join(' ')
      end
    end

    class Section < Node
      def menu_output
        <<~HTML
          <li>
            <div class="scope-title">#{name}</div>
            <ul class="scoped">#{children.map(&:menu_output).join}</ul>
          </li>
        HTML
      end

      def signatures_output
        signatures = children.map do |leaf|
          %(<div class="resource-sig">#{leaf.signature}</div>)
        end.join

        <<-HTML
        <div class="section-response">
          <div class="response-topbar">#{name} ENDPOINTS</div>
          <div class="section-endpoints">#{signatures}</div>
        </div>
        HTML
      end
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

    def read_files
      visitor = Visitors::Reader.new
      self.class.tree.each { |n| n.accept(visitor) }
    end

    def menu_output
      self.class.tree.map(&:menu_output).join
    end

    def normalize_tree
      visitor = Normalizer.new
      self.class.tree.each { |n| n.accept(visitor) }
    end

    def to_html
      visitor = Reader.new
      self.class.tree.each { |n| n.accept(visitor) }
      visitor.result
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
          Nodes::Leaf.new(File.join(@content_dir, "#{f}.md"), f)
        else
          dir = File.join(@content_dir, f["name"])
          traverse_directory(dir, name: f["name"], type: f["type"])
        end
      end

      # normalize_tree
    end

    def traverse_directory(dir, name:, type:)
      children = Dir.each_child(dir).map do |filename|
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
      when "resources_group" then Nodes::ResourcesGroup
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
