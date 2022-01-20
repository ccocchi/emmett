module Emmett
  module Nodes
    class Resource < Simple
      def menu_output
        # TODO: we should use desc here instead
        head, *tail = children
        clean_name = name.tr('_', ' ').split.map!(&:capitalize).join(' ')

        # TODO:
        # #{head.anchor(clean_name, class_list: 'expandable')}

        <<-HTML
          <li data-anchor="#{clean_name}">
            <a class="expandable" href="#"><span>#{clean_name}</span></a>
            <ul>#{children.map(&:menu_output).join}</ul>
          </li>
        HTML
      end
    end
  end
end
