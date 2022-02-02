module Emmett
  module Nodes
    class Leaf < Simple
      attr_accessor :metadata, :content, :example, :resource

      def anchor
        resource ? "#{resource.name}-#{name}" : name
      end

      def leaf?
        true
      end

      def member?
        metadata["path"].include?("/:id/")
      end

      def method
        metadata["method"]
      end
    end
  end
end
