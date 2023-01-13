# frozen_string_literal: true

require "thor"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Foresite; end
