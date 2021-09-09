require 'yaml'

module Emmett
  class Config
    def initialize(config_path)
      @path = config_path
      load
    end

    def changed?
      @changed
    end

    def load
      file = File.open(@path)
      @raw = YAML.load(file.read)
      @ts = file.mtime
      @changed = true
    end

    def reload
      @changed = false
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
  end
end