require_relative "emmett/version"

require_relative "emmett/nodes/simple"
require_relative "emmett/nodes/resources_group"
require_relative "emmett/nodes/resource"
require_relative "emmett/nodes/section"
require_relative "emmett/nodes/leaf"

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