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
        resource_name = n.name.tr('_', ' ').split.map!(&:capitalize).join(' ')
        @resource = n

        <<~HTML
          <li data-anchor="#{n.name}">
            <a class="expandable" href="#{anchor(n.desc)}"><span>#{resource_name}</span></a>
            <ul>#{visit_Array(n.children)}</ul>
          </li>
        HTML
      ensure
        @resource = nil
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
        name = n.metadata&.[]("menu_title") || n.name
        %{<li><a href="#{anchor(n)}"><span>#{name}</span></a></li>}
      end

      def anchor(n)
        @resource ? "##{@resource.name}-#{n.name}" : "##{n.name}"
      end
    end
  end
end
