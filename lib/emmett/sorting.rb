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
          .sort! { |(n1, s1), (n2, s2)|
            o = s1 <=> s2
            o == 0 ? n1.endpoint_path.length <=> n2.endpoint_path.length : o
          }
          .map!(&:first)
      end

      def heuristic_score(node)
        path  = node.endpoint_path
        score = METHOD_SCORE[node.method]

        idx = path.index(":id")
        idx ||= path.index(":#{node.resource.param}") if node.resource

        score += 5 if idx && node.method != "POST"
        score += 5 if idx && path.length > idx + 4

        score
      end
    end
  end
end
