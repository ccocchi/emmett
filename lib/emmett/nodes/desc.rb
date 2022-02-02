module Emmett
  module Nodes
    class Desc
      attr_reader :content, :resource

      def initialize(resource, content = nil)
        @resource = resource
        @content = content || "<h1>#{resource.name.capitalize}</h1>"
      end

      def name
        "desc"
      end
    end
  end
end
