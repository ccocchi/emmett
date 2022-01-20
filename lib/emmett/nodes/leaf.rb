module Emmett
  module Nodes
    class Leaf < Simple
      attr_accessor :metadata, :content, :example

      def menu_output
        menu_title = metadata&.[]("menu_title") || name
        "<li><a><span>#{menu_title}</span></a></li>"
      end
    end
  end
end
