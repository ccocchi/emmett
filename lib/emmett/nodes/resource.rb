module Emmett
  module Nodes
    class Resource < Simple
      attr_writer :children
      attr_accessor :desc

      def param
        "#{ActiveSupport::Inflector.singularize(name)}_id"
      end
    end
  end
end
