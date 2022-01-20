module Emmett
  module Nodes
    class Simple
      attr_reader   :name, :path
      attr_accessor :children
      attr_accessor :ts, :output_cache, :menu_output_cache

      def initialize(path, name, children = nil)
        @path = path
        @name = name
        @children = children
      end

      def accept(visitor)
        visitor.visit(self)
      end

      def reset_cache(time)
        @ts = time
        @output_cache = nil
        @menu_output_cache = menu_output
      end

      def output
        children.map(&:output).join
      end
    end
  end
end
