module Emmett
  module Visitors
    class Normalizer
      include Core

      private

      def visit_Resource(n)
        desc = nil

        normalized = n.children.each_with_object([]) do |c, res|
          if c.is_a?(Nodes::Leaf) && c.name == "desc"
            desc = c
          else
            res << c
          end
        end

        n.children  = normalized
        n.desc      = Nodes::Desc.new(n, desc&.content)
      end
    end
  end
end
