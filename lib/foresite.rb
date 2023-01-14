# frozen_string_literal: true

require "thor"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Foresite
  DIRNAME_MARKDOWN = "md"
  DIRNAME_OUTPUT = "out"

  PATH_TO_SAMPLE_TEMPLATE = File.join(__dir__, "skeleton", "sample_template.rhtml")
  FILENAME_TEMPLATE = "template.rhtml"

  ENV_ROOT = 'FORESITE_ROOT'

  ##
  # Gets the root directory for the current CLI command.
  #
  # @return [String] Path to foresite root directory.
  #
  def self.get_root_directory
    ENV[ENV_ROOT] || Dir.pwd
  end
end
