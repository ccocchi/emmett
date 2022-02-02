module Emmett
  module Visitors
    class MenuOutput
      include Core

      private

      def visit_Array(ary)
        ary.map { |c| visit(c) }.join
      end

      def visit_Root(n)
        orphans, rest = n.children.partition { |n| n.is_a?(Nodes::Leaf) }

        <<~HTML
          <div class="sidebar-nav-group">
            <ul>#{visit_Array(orphans)}</ul>
          </div>
          #{visit_Array(rest)}
        HTML
      end

      def visit_ResourcesGroup(n)
        title = "<h5 class=\"nav-group-title\">#{n.name}</h5>" if n.name&.length > 0

        <<~HTML
          <div class="sidebar-nav-group">
            #{title}
            <ul>#{visit_Array(n.children)}</ul>
          </div>
        HTML
      end

      def visit_Resource(n)
        human_name = n.name.tr('_', ' ').split.map!(&:capitalize).join(' ')

        <<~HTML
          <li data-anchor="#{n.name}">
            <a class="expandable" href="##{n.desc.anchor}"><span>#{human_name}</span></a>
            <ul>#{visit_Array(n.children)}</ul>
          </li>
        HTML
      end

      def visit_Section(n)
        <<~HTML
          <li>
            <div class="scope-title">#{n.name}</div>
            <ul class="scoped">#{visit_Array(n.children)}</ul>
          </li>
        HTML
      end

      def visit_Leaf(n)
        human_name = n.metadata&.fetch("menu_title", n.name)
        %{<li><a href="##{n.anchor}"><span>#{human_name}</span></a></li>}
      end
    end
  end
end
