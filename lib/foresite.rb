# frozen_string_literal: true

require "thor"
require "kramdown"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Foresite
  DIRNAME_MARKDOWN = "md"
  DIRNAME_OUTPUT = "out"
  DIRNAME_ERB = "erb"

  PATH_TO_DEFAULT_WRAPPER_HTML = File.join(__dir__, "skeleton", "wrapper.html.erb")
  PATH_TO_DEFAULT_LIST_HTML = File.join(__dir__, "skeleton", "_list.html.erb")
  PATH_TO_DEFAULT_POST_MD = File.join(__dir__, "skeleton", "post.md.erb")
  FILENAME_WRAPPER_HTML = "wrapper.html.erb"
  FILENAME_LIST_HTML = "_list.html.erb"
  FILENAME_POST_MD = "post.md.erb"

  ENV_ROOT = "FORESITE_ROOT"

  # @todo Provide option to use template instead.
  def self.default_markdown_content(title, date)
    <<~EOF
      # #{title}

      #{date}

    EOF
  end

  ##
  # Gets the root directory for the current CLI command.
  #
  # @return [String] Path to foresite root directory.
  #
  def self.get_root_directory
    ENV[ENV_ROOT] || Dir.pwd
  end
end
