module Emmett
  module Nodes
    class Root
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def accept(visitor)
        children.each { |n| visitor.visit(n) }
      end

      def menu_output
        orphans, rest = children.partition { |n| n.is_a?(Nodes::Leaf) }

        <<~HTML
          <div class="sidebar-nav-group">
            <ul>#{orphans.map!(&:menu_output).join}</ul>
          </div>
          #{rest.map!(&:menu_output).join}
        HTML
      end

      def output
        children.map(&:output).join
      end
    end
  end
end
