module Emmett
  class Printer
    def initialize
      @spaces = 0
    end

    def visit(o)
      name = o.class.name.split('::').last
      send("visit_#{name}", o)
    end

    def out(txt)
      print " " * @spaces
      puts txt
    end

    def indenting
      @spaces += 2
      yield
      @spaces -= 2
    end

    private

    def visit_Resource(n)
      out "Resource: path=#{n.path}"
      indenting {
        n.children.each { |c| visit(c) }
      }
    end

    def visit_ResourcesGroup(n)
      out "ResourceGroup: path=#{n.path}"
      indenting {
        n.children.each { |c| visit(c) }
      }
    end

    def visit_Section(n)
      out "Section: path=#{n.path}"
      indenting {
        n.children.each { |c| visit(c) }
      }
    end

    def visit_Leaf(n)
      out "Leaf: path=#{n.filename}"
    end
  end
end