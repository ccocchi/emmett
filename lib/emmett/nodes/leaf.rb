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

      def endpoint?
        metadata&.key?("path") && metadata.key?("method")
      end

      def method
        metadata["method"]
      end

      def endpoint_path
        metadata["path"]
      end
    end
  end
end
