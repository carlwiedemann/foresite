# frozen_string_literal: true

require "thor"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Foresite
  DIRNAME_MARKDOWN = "md"
  DIRNAME_OUTPUT = "out"

  PATH_TO_SAMPLE_TEMPLATE = File.join(__dir__, "skeleton", "sample_template.rhtml")
end
