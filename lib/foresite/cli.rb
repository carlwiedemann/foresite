module Foresite
  ##
  # Cli class.
  #
  # For CLI functionality to generate static content.
  #
  class Cli < ::Thor
    ##
    # Ensure that failures exit with a status of zero.
    #
    def self.exit_on_failure?
      true
    end

    desc "init", "Initializes foresite in current directory"
    long_desc <<-LONGDESC
      Initializes foresite in the current directory.

      Creates `#{Foresite::DIRNAME_MARKDOWN}/` for storing editable markdown posts, `#{Foresite::DIRNAME_OUTPUT}/` for storing generated HTML, and `#{Foresite::DIRNAME_ERB}` for storing editable template.

      Does not overwrite existing subdirectories.
    LONGDESC

    def init
      unless Foresite.root_exists?
        warn("Nonexistent directory #{Foresite.get_path_to_root_directory}")
        exit(1)
      end

      unless Foresite.root_writable?
        warn("Cannot write to directory #{Foresite.get_path_to_root_directory}")
        exit(1)
      end

      Foresite.touch_directories.map { $stdout.puts(_1) }
      Foresite.copy_templates.map { $stdout.puts(_1) }
    end

    desc "touch [TITLE]", "Creates new `.md` file with TITLE in `#{Foresite::DIRNAME_MARKDOWN}` directory"
    long_desc <<-LONGDESC
      Creates a markdown file for usage as a post, with optional title.

      The name of the file will be the current date suffixed by the `TITLE` argument. The current date will be formatted as `YYYY-MM-DD` and the title will be transformed to use lowercase alphanumeric characters, separated by hyphens.

      Example: (If today is 14 January 2023, and the command is run from /Users/carlos/my_project)

      $ foresite touch "Happy new year!"
      \x5> Created #{Foresite::DIRNAME_MARKDOWN}/2023-01-14-happy-new-year.md
    LONGDESC

    def touch(title)
      unless Foresite.subdirectories_exist?
        warn("Missing subdirectories, try running `foresite init`")
        exit(1)
      end

      date_ymd = Time.now.strftime("%F")
      slug = title.downcase.gsub(/[^a-z]/i, " ").strip.gsub(/ +/, "-")

      path = Foresite.get_path_to_md_file("#{date_ymd}-#{slug}.md")

      if File.exist?(path)
        $stdout.puts("File #{Foresite.relative_path(path)} already exists")
      else
        File.write(path, Foresite.render_post(title,date_ymd))
        $stdout.puts("Created #{Foresite.relative_path(path)}")
      end
    end

    desc "build", "Generates HTML from markdown into `#{Foresite::DIRNAME_OUTPUT}` directory"
    long_desc <<-LONGDESC
      Creates HTML files from all markdown posts and writes them to the `#{Foresite::DIRNAME_OUTPUT}` directory.

      The names of the HTML files match corresponding markdown files with extension `.html` instead of `.md`.
    LONGDESC

    def build
      unless Foresite.subdirectories_exist?
        warn("Missing subdirectories, try running `foresite init`")
        exit(1)
      end

      # Wipe all output files.
      Dir.glob(File.join(Foresite.get_path_to_out, "*.html")).each { File.delete(_1) }

      markdown_paths = Dir.glob(File.join(Foresite.get_path_to_md, "*.md"))

      if markdown_paths.count == 0
        warn("No markdown files, try running `foresite touch`")
        exit(1)
      end

      links = markdown_paths.map do |markdown_path|
        markdown_content = File.read(markdown_path)

        filename_markdown = File.basename(markdown_path)
        html_path = Foresite.get_path_to_out_file(filename_markdown.gsub(/\.md$/, ".html"))

        File.write(html_path, Foresite.render_wrapped(markdown_content))
        $stdout.puts("Created #{Foresite.relative_path(html_path)}")

        # Extract date if it exists.
        match_data = /\d{4}-\d{2}-\d{2}/.match(filename_markdown)

        {
          date_ymd: match_data.nil? ? "" : match_data[0],
          href: File.basename(html_path),
          title: markdown_content.split("\n").first { |line| /^# [a-z]/i =~ line }.gsub(/^#/, "").strip
        }
      end

      # Generate index file.
      index_html_path = Foresite.get_path_to_out_file("index.html")
      File.write(index_html_path, Foresite.render_wrapped_index(links))

      $stdout.puts("Created #{Foresite.relative_path(index_html_path)}")
    end
  end
end
