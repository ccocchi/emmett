module Emmett
  module Nodes
    class Simple
      attr_reader :name, :path, :children, :ts

      def initialize(path, name, children = nil)
        @path = path
        @name = name
        @children = children
      end

      def reset_cache(time)
        @ts = time
      end

      def leaf?
        false
      end
    end
  end
end
