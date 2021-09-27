require 'emmett/content_parser'

module Emmett
  class Reader
    attr_reader :current_resource

    def initialize
      @current_resource = nil
    end

    def visit(o)
      name = o.class.name.split('::').last
      send("visit_#{name}", o)
    end

    private

    def visit_ResourcesGroup(n)
      # path = n.path
      # time = File.mtime(path)

      # return if n.ts && time <= n.ts

      n.children.each { |c| visit(c) }


      # n.ts = time
    end

    def visit_Resource(n)
      @current_resource = n.name
      n.children.each { |c| visit(c) }
    ensure
      @current_resource = nil
    end

    def visit_Section(n)
      n.children.each { |c| visit(c) }
    end

    def visit_Leaf(n)
      path = n.filename
      time = File.mtime(path)

      return if n.ts && time <= n.ts

      file = File.open(path)
      raw_content = file.read

      if raw_content.start_with?('---')
        idx = raw_content.index('---', 4)
        raise 'bad format' unless idx
        n.metadata = parse_metadata(YAML.load(raw_content.slice!(0, idx + 3)))
      end

      n.content, n.example = raw_content.split('$$$').map! { |c| Emmett::ContentParser.to_html(c) }
      n.ts = file.mtime
      n.set_identifier(current_resource)
    end

    def parse_metadata(hash)
      hash.slice('id', 'menu_title', 'path', 'method')
    end
  end
end