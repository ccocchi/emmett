require "roda"
require "tilt"
require "tilt/erubi"

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
        @config = Emmett.config
        @config.reload

        @tree = Emmett.tree
        @tree.refresh

        view('index')
      end
    end
  end
end
