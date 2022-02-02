require "erubi"
require "byebug"

require_relative "emmett/nodes/simple"
require_relative "emmett/nodes/resources_group"
require_relative "emmett/nodes/resource"
require_relative "emmett/nodes/section"
require_relative "emmett/nodes/leaf"
require_relative "emmett/nodes/desc"
require_relative "emmett/nodes/root"

require_relative "emmett/sorting"
require_relative "emmett/config"
require_relative "emmett/tree"

module Emmett
  class Error < StandardError; end

  @config = Config.new('config.yml')
  @tree   = Tree.new(@config)

  def self.config
    @config
  end

  def self.tree
    @tree
  end
end
