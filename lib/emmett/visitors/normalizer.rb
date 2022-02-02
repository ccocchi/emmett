module Emmett
  module Visitors
    class Normalizer
      include Core

      attr_reader :current_resource

      def initialize
        @current_resource = nil
      end

      private

      def visit_Resource(n)
        desc = nil

        normalized = n.children.each_with_object([]) do |c, res|
          if c.leaf? && c.name == "desc"
            desc = c
          else
            res << c
          end
        end

        n.children  = Sorting.default(normalized)
        n.desc      = Nodes::Desc.new(n, desc&.content)

        @current_resource = n
        visit_Array(n.children)
        @current_resource = nil
      end

      def visit_Leaf(n)
        n.resource = current_resource if current_resource
      end
    end
  end
end
