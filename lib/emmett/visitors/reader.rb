require 'emmett/content_parser'

module Emmett::Visitors
  class Reader
    include Core

    attr_reader :current_resource

    def initialize
      @current_resource = nil
    end

    private

    def visit_Resource(n)
      @current_resource = n
      super
    ensure
      @current_resource = nil
    end

    def visit_Leaf(n)
      path = n.path
      time = File.mtime(path)

      return if n.ts && time <= n.ts

      file = File.open(path)
      raw_content = file.read

      if raw_content.start_with?('---')
        idx = raw_content.index('---', 4)
        raise 'bad format' unless idx
        n.metadata = parse_metadata(YAML.load(raw_content.slice!(0, idx + 3)))
      end

      n.content, n.example = ::Emmett::ContentParser.parse(raw_content)
      n.reset_cache(file.mtime)
      n.resource = @current_resource
    end

    def parse_metadata(hash)
      hash.slice('id', 'menu_title', 'path', 'method')
    end
  end
end
