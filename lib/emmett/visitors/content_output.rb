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

        def self.endpoint_signature(n)
          <<~HTML
            <div class="endpoint-def">
              <div class="method method__#{n.method.downcase}">#{n.method.upcase}</div>
              <div class="path">#{n.endpoint_path}</div>
            </div>
          HTML
        end

        def self.endpoints_summary(endpoints, name: nil)
          signatures = endpoints.map do |n|
            <<~HTML
              <div class="resource-sig">
                <a href="##{n.anchor}">#{endpoint_signature(n)}</a>
              </div>
            HTML
          end

          title = name ? "#{name} ENDPOINTS" : "ENDPOINTS"

          <<~HTML
            <div class="section-response">
              <div class="response-topbar">#{title}</div>
              <div class="section-endpoints">#{signatures.join}</div>
            </div>
          HTML
        end
      end

      def initialize
        @in_section = false
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
        orphans, sections = n.children.partition(&:leaf?)
        sections.map! { |n| Render.endpoints_summary(n.children, name: n.name) }

        if orphans.any?
          orphans.keep_if(&:endpoint?)
          sections.prepend(Render.endpoints_summary(orphans))
        end

        desc = n.desc
        desc_output = Render.section(desc.anchor, desc.content, sections.join, n.name)

        <<~HTML
          <section class="head-section">
            #{desc_output}
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
