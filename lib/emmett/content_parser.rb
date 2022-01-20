require 'rouge'
require 'redcarpet'

module Emmett
  module ContentParser
    CONTENT_EXAMPLE_SEP = '$$$'

    class Renderer < Redcarpet::Render::Base
      attr_reader :rouge_formatter, :rouge_lexer

      def initialize(*args)
        super
        @rouge_formatter  = Rouge::Formatters::HTML.new
        @rouge_lexer      = Rouge::Lexers::JSON.new
      end

      def emphasis(text)
        "<em>#{text}</em>"
      end

      def double_emphasis(text)
        "<strong>#{text}</strong>"
      end

      def paragraph(text)
        "<p>#{text}</p>"
      end

      def link(link, title, content)
        %(<a title="#{title}" href="#{link}">#{content}</a>)
      end

      def header(text, level)
        if level == 4
          %(<div class="header-table">#{text}</div>)
        else
          "<h#{level}>#{text}</h#{level}>"
        end
      end

      def table(header, body)
        <<-HTML
          <div class="table-wrapper">
            <div class="header-table">#{@table_title}</div>
            <table>
              <thead></thead>
              <tbody>#{body}</tbody>
            </table>
          </div>
        HTML
      ensure
        @table_title = nil
      end

      def table_row(content)
        content.empty? ? nil : "<tr>#{content}</tr>"
      end

      def table_cell(content, alignment)
        if !alignment
          @table_title = content unless content.empty?
          return
        end

        c = case alignment
        when 'left'   then 'definition'.freeze
        when 'right'  then 'property'.freeze
        end

        "<td class=\"cell-#{c}\">#{content}</td>"
      end

      def block_html(raw_html)
        raw_html
      end

      def codespan(code)
        "<code>#{code}</code>"
      end

      def block_code(code, language)
        if language == 'attributes' || language == 'parameters'
          AttributesComponent.new(code, language).output
        elsif language == 'response'
          format_code('RESPONSE', code)
        elsif language == 'title_and_code'
          title, _code = code.split("\n", 2)
          title ||= 'RESPONSE'
          format_code(title, _code)
        end
      end

      private def format_code(title, code)
        <<-HTML
        <div class="section-response">
          <div class="response-topbar">#{title}</div>
          <pre><code>#{rouge_formatter.format(rouge_lexer.lex(code.strip))}</code></pre>
        </div>
        HTML
      end
    end

    class AttributesComponent
      # Needed because we can't call the same rendered within itself.
      @@renderer = Redcarpet::Markdown.new(::Emmett::ContentParser::Renderer, {
        underline:            true,
        space_after_headers:  true,
        fenced_code_blocks:   true,
        no_intra_emphasis:    true
      })

      def initialize(raw_attrs, title)
        @attributes = YAML.load(raw_attrs)
        @title      = title
      end

      # template = Erubi::Engine.new(File.read(File.expand_path('../src/attributes.erb', __dir__)))
      # class_eval <<-RUBY
      #   define_method(:output) { #{template.src} }
      # RUBY

      def output
        "ATTRIBUTES"
      end

      def to_html(text)
        @@renderer.render(text) if text
      end
    end

    @@renderer = Redcarpet::Markdown.new(Renderer, {
      underline:            true,
      space_after_headers:  true,
      fenced_code_blocks:   true,
      no_intra_emphasis:    true,
      tables:               true
    })

    def self.parse(raw)
      raw.split(CONTENT_EXAMPLE_SEP, 2).map! { |c| to_html(c) }
    end

    def self.to_html(text)
      @@renderer.render(text)
    end
  end
end
