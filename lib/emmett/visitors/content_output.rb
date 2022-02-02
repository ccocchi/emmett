module Emmett
  module Visitors
    class ContentOutput
      include Core

      module Render
        template = Erubi::Engine.new(File.read('src/views/section.erb'))
        instance_eval <<-ERB
          def section(id, content, example, resource_name = nil)
            #{template.src}
          end
        ERB
      end

      private

      def visit_Array(ary)
        ary.map { |c| visit(c) }.join
      end

      def visit_Root(n)
        visit_Array(n.children)
      end

      def visit_ResourcesGroup(n)
        visit_Array(n.children)
      end

      def visit_Resource(n)
        desc = n.desc
        output = Render.section(desc.anchor, desc.content, "", n.name)

        <<~HTML
          <section class="head-section">
            #{output}
            #{visit_Array(n.children)}
          </section>
        HTML
      end

      def visit_Section(n)
        visit_Array(n.children)
      end

      def visit_Leaf(n)
        Render.section(n.anchor, n.content, n.example)
      end
    end
  end
end
