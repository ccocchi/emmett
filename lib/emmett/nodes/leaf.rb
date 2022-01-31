module Emmett
  module Nodes
    class Leaf < Simple
      attr_accessor :metadata, :content, :example
      attr_accessor :resource

      def menu_output
        menu_title = metadata&.[]("menu_title") || name
        "<li><a><span>#{menu_title}</span></a></li>"
      end

      template = Erubi::Engine.new(File.read('src/views/section.erb'))
      module_eval <<-RUBY
        define_method(:output) { #{template.src} }
      RUBY

      def main_section?
        false
      end

      def anchor_id
        resource ? "#{resource.name}-#{name}" : name
      end

      def html_content
        content
      end

      def html_example
        example
      end
    end
  end
end
