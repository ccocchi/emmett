module Emmett
  module Nodes
    class ResourcesGroup < Simple
      def menu_output
        title = "<h5 class=\"nav-group-title\">#{name}</h5>" if name&.length > 0

        <<~HTML
          <div class="sidebar-nav-group">
            #{title}
            <ul>#{children.map(&:menu_output).join}</ul>
          </div>
        HTML
      end
    end
  end
end
