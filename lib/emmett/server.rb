require "roda"
require "tilt"
require "tilt/erubi"

require "emmett/config"
require "emmett/converter"

module Emmett
  class Server < Roda
    plugin :render, views: 'src/views', layout: false

    plugin :assets,
      path: 'src',
      css: 'application.scss',
      css_compressor: :none,
      css_opts: { source_map_embed: true, source_map_contents: true, source_map_file: "." }

    plugin :static, ['/js'], root: 'src'

    def development?
      ENV['RACK_ENV'] == 'development'
    end

    route do |r|
      r.assets

      r.root do
        @config     = Emmett.reload_config
        @converter  = Converter.new(@config)

        @converter.pretty_print

        view('index')
      end
    end
  end
end