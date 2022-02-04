require 'emmett/content_parser'

module Emmett::Visitors
  class Reader
    include Core

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
      if n.endpoint?
        n.example.sub!("RESPONSE", ContentOutput::Render.endpoint_signature(n))
      end

      n.reset_cache(file.mtime)
    end

    def parse_metadata(hash)
      hash.slice('menu_title', 'path', 'method')
    end
  end
end
