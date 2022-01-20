module Emmett::Visitors
  module Core
    DISPATCH = Hash.new do |hash, node_class|
      hash[node_class] = :"visit_#{node_class.name.split('::').last}"
    end

    def visit(o)
      m = DISPATCH[o.class]
      send DISPATCH[o.class], o
    end

    private

    def visit_ResourcesGroup(n)
      n.children.each { |c| visit(c) }
    end

    def visit_Resource(n)
      n.children.each { |c| visit(c) }
    end

    def visit_Section(n)
      n.children.each { |c| visit(c) }
    end

    def visit_Leaf(n)
    end
  end
end
