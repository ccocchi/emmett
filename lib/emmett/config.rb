require 'yaml'

module Emmett
  class Config
    def initialize(config_path)
      @path = config_path
      @changed = false
      @raw = nil
      @ts = 0

      load
    end

    def changed?
      @changed
    end

    def reload
      tm = File.mtime(@path)
      load if tm > @ts
      self
    end

    %w[
      app_name
      title
      content_dir
      content
    ].each do |meth|
      define_method(meth) do
        @raw[meth]
      end
    end

    private

    def load
      file  = File.open(@path)
      raw   = YAML.load(file.read)

      @changed = raw["content"] != @raw["content"] if @raw
      @raw = raw
      @ts = file.mtime
    end
  end
end
