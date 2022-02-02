module Emmett
  module Nodes
    class Resource < Simple
      attr_writer :children
      attr_accessor :desc
    end
  end
end
