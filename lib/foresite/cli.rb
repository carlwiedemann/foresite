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
      Creates a directory `#{Foresite::DIRNAME_MARKDOWN}` for storing posts, a directory `#{Foresite::DIRNAME_OUTPUT}` for storing generated output, and a file
      `template.rhtml` as a sample template.

      Does not overwrite existing directories.
    LONGDESC

    def init
      path_to_root_directory = Foresite.get_root_directory

      if Dir.exist?(path_to_root_directory)
        if File.writable?(path_to_root_directory)
          # Create md directory.
          full_path_to_dir_md = File.join(path_to_root_directory, Foresite::DIRNAME_MARKDOWN)
          if Dir.exist?(full_path_to_dir_md)
            $stdout.puts("#{Foresite::DIRNAME_MARKDOWN}/ already exists")
          else
            Dir.mkdir(full_path_to_dir_md)
            $stdout.puts("Created #{Foresite::DIRNAME_MARKDOWN}/")
          end

          # Create output directory.
          full_path_to_dir_out = File.join(path_to_root_directory, Foresite::DIRNAME_OUTPUT)
          if Dir.exist?(full_path_to_dir_out)
            $stdout.puts("#{Foresite::DIRNAME_OUTPUT}/ already exists")
          else
            Dir.mkdir(full_path_to_dir_out)
            $stdout.puts("Created #{Foresite::DIRNAME_OUTPUT}/")
          end

          # Create erb directory.
          full_path_to_dir_erb = File.join(path_to_root_directory, Foresite::DIRNAME_ERB)
          if Dir.exist?(full_path_to_dir_erb)
            $stdout.puts("#{Foresite::DIRNAME_ERB}/ already exists")
          else
            Dir.mkdir(full_path_to_dir_erb)
            $stdout.puts("Created #{Foresite::DIRNAME_ERB}/")
          end

          # Create post.
          full_path_to_file_post = File.join(full_path_to_dir_erb, Foresite::FILENAME_POST_MD)
          relative_path_to_file_post = File.join(Foresite::DIRNAME_ERB, Foresite::FILENAME_POST_MD)
          if File.exist?(full_path_to_file_post)
            $stdout.puts("#{relative_path_to_file_post} already exists")
          else
            File.copy_stream(Foresite::PATH_TO_DEFAULT_POST_MD, full_path_to_file_post)
            $stdout.puts("Created #{relative_path_to_file_post}")
          end

          # Create wrapper.
          full_path_to_file_wrapper = File.join(full_path_to_dir_erb, Foresite::FILENAME_WRAPPER_HTML)
          relative_path_to_file_wrapper = File.join(Foresite::DIRNAME_ERB, Foresite::FILENAME_WRAPPER_HTML)
          if File.exist?(full_path_to_file_wrapper)
            $stdout.puts("#{relative_path_to_file_wrapper} already exists")
          else
            File.copy_stream(Foresite::PATH_TO_DEFAULT_WRAPPER_HTML, full_path_to_file_wrapper)
            $stdout.puts("Created #{relative_path_to_file_wrapper}")
          end

          # Create list.
          full_path_to_file_list = File.join(full_path_to_dir_erb, Foresite::FILENAME_LIST_HTML)
          relative_path_to_file_list = File.join(Foresite::DIRNAME_ERB, Foresite::FILENAME_LIST_HTML)
          if File.exist?(full_path_to_file_list)
            $stdout.puts("#{relative_path_to_file_list} already exists")
          else
            File.copy_stream(Foresite::PATH_TO_DEFAULT_LIST_HTML, full_path_to_file_list)
            $stdout.puts("Created #{relative_path_to_file_list}")
          end

        else
          warn("Cannot write to directory #{path_to_root_directory}")
          exit(1)
        end
      else
        warn("Nonexistent directory #{path_to_root_directory}")
        exit(1)
      end
    end

    desc "touch [TITLE]", "Creates new `.md` file with TITLE in `#{Foresite::DIRNAME_MARKDOWN}` directory"
    long_desc <<-LONGDESC
      Creates a markdown file for usage as a post, with optional title.

      The name of the file will be the current date suffixed by the `TITLE` argument. The current date will be formatted
      as `YYYY-MM-DD` and the title will be transformed to use lowercase alphanumeric characters, separated by hyphens.

      Example: (If today is 14 January 2023, and the command is run from /Users/carlos/my_project)

      $ foresite touch "Happy new year!"
      \x5> Created file /Users/carlos/my_project/#{Foresite::DIRNAME_MARKDOWN}/2023-01-14-happy-new-year.md
    LONGDESC

    def touch(title)
      full_path_to_dir_md = File.join(Foresite.get_root_directory, Foresite::DIRNAME_MARKDOWN)

      unless Dir.exist?(full_path_to_dir_md)
        warn("No `#{Foresite::DIRNAME_MARKDOWN}` directory, did you run `foresite init` yet?")
        exit(1)
      end

      time_now = Time.now

      ymd = time_now.strftime("%F")
      slug = title.downcase.gsub(/[^a-z]/i, " ").strip.gsub(/ +/, "-")

      filename_md = "#{ymd}-#{slug}.md"
      full_path_to_file_md = File.join(full_path_to_dir_md, filename_md)
      relative_path_to_file_md = File.join(Foresite::DIRNAME_MARKDOWN, filename_md)

      if File.exist?(full_path_to_file_md)
        $stdout.puts("File #{relative_path_to_file_md} already exists")
      else
        File.write(full_path_to_file_md, Foresite.default_markdown_content(title, ymd))
        $stdout.puts("Created #{relative_path_to_file_md}")
      end
    end

    desc "build", "Generates HTML from markdown into `#{Foresite::DIRNAME_OUTPUT}` directory"
    long_desc <<-LONGDESC
      Creates HTML files from all markdown posts and writes them to the `#{Foresite::DIRNAME_OUTPUT}` directory.

      The names of the HTML files should match the names of the markdown files but will use `.html` as the file
      extension instead of `.md`.
    LONGDESC

    def build
      path_to_root_directory = Foresite.get_root_directory
      full_path_to_dir_md = File.join(path_to_root_directory, Foresite::DIRNAME_MARKDOWN)
      full_path_to_dir_out = File.join(path_to_root_directory, Foresite::DIRNAME_OUTPUT)
      full_path_to_dir_erb = File.join(path_to_root_directory, Foresite::DIRNAME_ERB)
      full_path_to_wrapper_html = File.join(full_path_to_dir_erb, Foresite::FILENAME_WRAPPER_HTML)

      [full_path_to_dir_md, full_path_to_dir_out].any? do |path|
        unless Dir.exist?(path)
          warn("No `#{Foresite::DIRNAME_MARKDOWN}` directory or `#{Foresite::DIRNAME_OUTPUT}` directory, did you run `foresite init` yet?")
          exit(1)
        end
      end

      # Wipe all output files.
      Dir.glob(File.join(full_path_to_dir_out, "*")).each { File.delete(_1) }

      markdown_files = Dir.glob(File.join(full_path_to_dir_md, "*.md"))

      if markdown_files.count == 0
        warn("No `.md` files, try running `foresite touch`")
        exit(1)
      end

      links = []
      markdown_files.each do |path_to_markdown|
        markdown_content = File.read(path_to_markdown)

        content = ::Kramdown::Document.new(markdown_content).to_html
        filename_markdown = File.basename(path_to_markdown)
        filename_html = filename_markdown.gsub(/\.md$/, ".html")
        full_path_to_file_html = File.join(full_path_to_dir_out, filename_html)
        relative_path_to_file_html = File.join(Foresite::DIRNAME_OUTPUT, filename_html)

        File.write(full_path_to_file_html, Foresite::Renderer.render(full_path_to_wrapper_html, {
          content: content
        }))

        puts "Created #{relative_path_to_file_html}"

        title = markdown_content.split("\n").first { |line| /^# [a-z]/i =~ line }.gsub(/^#/, "").strip

        links.push({
          href: File.basename(full_path_to_file_html),
          title: title,
          date: /\d{4}-\d{2}-\d{2}/.match(filename_markdown)[0]
        })
      end

      if links.count > 0
        # @todo Can we use erb for this instead?
        inner_nav = links.map do |link|
          "  <li>#{link[:date]} <a href=\"#{link[:href]}\">#{link[:title]}</a></li>\n"
        end

        index_content = "<ul>\n#{inner_nav.join}</ul>\n"
      else
        index_content = ""
      end

      # Generate index file.
      index_filename = "index.html"
      full_path_to_index_html = File.join(full_path_to_dir_out, index_filename)
      relative_path_to_index_html = File.join(Foresite::DIRNAME_OUTPUT, index_filename)
      File.write(full_path_to_index_html, Foresite::Renderer.render(full_path_to_wrapper_html, {
        content: index_content
      }))

      puts "Created #{relative_path_to_index_html}"
    end
  end
end
