require_relative "emmett/version"

module Emmett
  class Error < StandardError; end

  def self.reload_config
    if @config
      @config.reload
    else
      @config = Config.new('config.yml')
    end
  end
end