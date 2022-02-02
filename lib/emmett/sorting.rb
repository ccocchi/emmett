module Emmett
  module Sorting
    class << self
      def default(nodes)
        leafs, sections = nodes.partition(&:leaf?)

        object = if (idx = leafs.find_index { |n| n.name == "object" })
          leafs.delete_at(idx)
        end

        heuristic_sort(leafs)
        leafs.prepend(object) if object

        sections.sort! { |a, b| a.name <=> b.name }.each { |s|
          heuristic_sort(s.children)
        }

        leafs.concat(sections)
      end

      private

      METHOD_SCORE = {
        "GET"     => 0,
        "POST"    => 1,
        "PUT"     => 2,
        "PATCH"   => 2,
        "DELETE"  => 3
      }

      def heuristic_sort(nodes)
        nodes
          .map! { |n| [n, heuristic_score(n)] }
          .sort! { |(_, s1), (_, s2)| s1 <=> s2 }
          .map!(&:first)
      end

      def heuristic_score(node)
        METHOD_SCORE[node.method] + (node.member? ? 10 : 0)
      end
    end
  end
end
