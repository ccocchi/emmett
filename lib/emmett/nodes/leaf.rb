module Emmett
  module Nodes
    class Leaf < Simple
      attr_accessor :metadata, :content, :example, :resource
    end
  end
end
