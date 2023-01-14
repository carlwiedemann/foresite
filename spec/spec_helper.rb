# frozen_string_literal: true

require "foresite"

TEST_DIR = __dir__

module ForesiteRSpec
  ##
  # Formats a line with a newline char at the end.
  #
  # @param [String] line Line to format.
  #
  # @return [String] Formatted line.
  #
  def self.cli_line(line)
    line + "\n"
  end

  ##
  # Formats lines with a newline char at the end of each, all joined.
  #
  # @param [Array<String>] lines Lines to format.
  #
  # @return [String] Formatted lines.
  #
  def self.cli_lines(lines)
    lines.map { cli_line(_1) }.join
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
