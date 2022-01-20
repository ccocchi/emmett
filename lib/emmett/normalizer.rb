require "byebug"

module Emmett
  class Normalizer
    include Visitors::Core

    private

    def visit_Resource(n)
      orphans  = []
      desc     = nil
      object   = nil

      sections = n.children.each_with_object([]) do |c, res|
        if c.is_a?(Nodes::Leaf) || c.is_a?(Converter::Leaf)
          if c.name == 'desc'
            desc = c
          elsif c.name == 'object'
            object = c
          else
            orphans << c
          end
        else
          res << c
        end
      end

      unless orphans.empty?
        sections.unshift(Nodes::Section.new(nil, orphans))
        n.children = sections
      end

      # TODO: desc is needed so we need to generate one if none is present
      n.desc = desc     if desc
      n.object = object if object
    end
  end
end
