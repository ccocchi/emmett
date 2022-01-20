module Emmett
  module Nodes
    class Section < Simple
      def menu_output
        <<~HTML
          <li>
            <div class="scope-title">#{name}</div>
            <ul class="scoped">#{children.map(&:menu_output).join}</ul>
          </li>
        HTML
      end
    end
  end
end
