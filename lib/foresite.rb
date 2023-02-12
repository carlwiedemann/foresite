# frozen_string_literal: true

require "erb"
require "thor"
require "kramdown"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Foresite
  DIRNAME_MARKDOWN = "md"
  DIRNAME_POST = "post"
  DIRNAME_ERB = "erb"

  FILENAME_POST_MD = "post.md.erb"
  FILENAME_WRAPPER_HTML = "wrapper.html.erb"
  FILENAME_LIST_HTML = "_list.html.erb"

  ENV_ROOT = "FORESITE_ROOT"

  PATH_TO_DEFAULTS = File.join(__dir__, "skeleton")

  def self.get_path_to_root
    ENV[ENV_ROOT] || Dir.pwd
  end

  def self.root_exists?
    Dir.exist?(get_path_to_root)
  end

  def self.root_writable?
    File.writable?(get_path_to_root)
  end

  def self.subdirectories_exist?
    [get_path_to_md, get_path_to_out, get_path_to_erb].all? do |path|
      Dir.exist?(path)
    end
  end

  def self.get_path_to_md
    File.join(get_path_to_root, DIRNAME_MARKDOWN)
  end

  def self.get_path_to_out
    File.join(get_path_to_root, DIRNAME_POST)
  end

  def self.get_path_to_erb
    File.join(get_path_to_root, DIRNAME_ERB)
  end

  def self.get_path_to_erb_file(file)
    File.join(get_path_to_erb, file)
  end

  def self.get_path_to_md_file(file)
    File.join(get_path_to_md, file)
  end

  def self.get_path_to_out_file(file)
    File.join(get_path_to_out, file)
  end

  def self.get_path_to_index_file
    File.join(get_path_to_root, "index.html")
  end

  def self.relative_path(full_path)
    full_path.gsub(get_path_to_root, "").gsub(Regexp.new("^#{File::SEPARATOR}"), "")
  end

  def self.render_erb_file(file, vars)
    Renderer.render(get_path_to_erb_file(file), vars)
  end

  def self.render_post(title, date_ymd)
    render_erb_file(FILENAME_POST_MD, {
      title: title,
      date_ymd: date_ymd
    })
  end

  def self.render_wrapped(title, markdown_content)
    render_erb_file(FILENAME_WRAPPER_HTML, {
      title: title,
      content: ::Kramdown::Document.new(markdown_content).to_html
    })
  end

  def self.render_wrapped_index(links)
    render_erb_file(FILENAME_WRAPPER_HTML, {
      content: render_erb_file(FILENAME_LIST_HTML, {
        links: links.reverse
      })
    })
  end

  def self.touch_directories
    [get_path_to_md, get_path_to_out, get_path_to_erb].map do |path|
      if Dir.exist?(path)
        "#{relative_path(path)}/ already exists"
      else
        Dir.mkdir(path)
        "Created #{relative_path(path)}/"
      end
    end
  end

  def self.copy_templates
    [FILENAME_POST_MD, FILENAME_WRAPPER_HTML, FILENAME_LIST_HTML].map do |filename|
      full_file_path = File.join(get_path_to_erb, filename)
      if File.exist?(full_file_path)
        "#{relative_path(full_file_path)} already exists"
      else
        File.copy_stream(File.join(PATH_TO_DEFAULTS, filename), full_file_path)
        "Created #{relative_path(full_file_path)}"
      end
    end
  end
end
