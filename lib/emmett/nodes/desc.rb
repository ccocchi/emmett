module Emmett
  module Nodes
    class Desc
      attr_reader :content, :resource

      def initialize(resource, content = nil)
        @resource = resource
        @content = content || "<h1>#{resource_name.capitalize}</h1>"
      end

      template = Erubi::Engine.new(File.read('src/views/section.erb'))
      module_eval <<-RUBY
        define_method(:output) { #{template.src} }
      RUBY

      def anchor_id
        "#{resource_name}-desc"
      end

      def main_section?
        true
      end

      def resource_name
        @resource.name
      end

      def html_content
        content
      end

      def html_example
      end
    end
  end
end
