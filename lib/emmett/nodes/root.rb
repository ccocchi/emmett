module Emmett
  module Nodes
    class Root
      attr_reader :children

      def initialize(children)
        @children = children
      end

      def accept(visitor)
        visitor.visit(self)
      end
    end
  end
end
