module Foresite
  ##
  # Cli class.
  #
  # For generation of files.
  #
  class Cli < ::Thor
    ##
    # Ensure that failures exit with a status of zero.
    #
    def self.exit_on_failure?
      true
    end

    desc "say_hello NAME", "say hello to NAME"

    def say_hello(name)
      puts "Hello #{name}"
    end

    desc "init", "Initializes foresite in current directory."
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
          # Create markdown directory.
          path_to_markdown_dir = File.join(path_to_root_directory, Foresite::DIRNAME_MARKDOWN)
          if Dir.exist?(path_to_markdown_dir)
            $stdout.puts("Directory #{path_to_markdown_dir} already exists")
          else
            Dir.mkdir(path_to_markdown_dir)
            $stdout.puts("Created directory #{path_to_markdown_dir}")
          end

          # Create output directory.
          path_to_output_dir = File.join(path_to_root_directory, Foresite::DIRNAME_OUTPUT)
          if Dir.exist?(path_to_output_dir)
            $stdout.puts("Directory #{path_to_output_dir} already exists")
          else
            Dir.mkdir(path_to_output_dir)
            $stdout.puts("Created directory #{path_to_output_dir}")
          end

          # Create base template.
          path_to_template_file = File.join(path_to_root_directory, Foresite::FILENAME_TEMPLATE)
          if File.exist?(path_to_template_file)
            $stdout.puts("File #{path_to_template_file} already exists")
          else
            File.copy_stream(Foresite::PATH_TO_SAMPLE_TEMPLATE, path_to_template_file)
            $stdout.puts("Created file #{path_to_template_file}")
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

    desc "touch [TITLE]", "Creates new `.md` file with TITLE in `#{Foresite::DIRNAME_MARKDOWN}` directory."
    long_desc <<-LONGDESC
      Creates a markdown file for usage as a post, with optional title.

      The name of the file will be the current date suffixed by the `TITLE` argument. The current date will be formatted
      as `YYYYMMDD` and the title will be transformed to use lowercase alphanumeric characters, separated by hyphens.

      Example: (If today is January 14, 2023, and the command is run from /Users/carlos/my_project)

      $ foresite touch "Happy new year!"
      \x5> Created file /Users/carlos/my_project/#{Foresite::DIRNAME_MARKDOWN}/20230114-happy-new-year.md
    LONGDESC

    def touch(title)
      path_to_markdown_directory = File.join(Foresite.get_root_directory, Foresite::DIRNAME_MARKDOWN)

      unless Dir.exist?(path_to_markdown_directory)
        warn("No `#{Foresite::DIRNAME_MARKDOWN}` directory, did you run `foresite init` yet?")
        exit(1)
      end

      time_now = Time.now

      base_filename = time_now.strftime("%Y%m%d")
      slug = title.downcase.gsub(/[^a-z]/i, " ").gsub(/ +/, "-")

      path_to_markdown_file = File.join(path_to_markdown_directory, "#{base_filename}-#{slug}.md")

      if File.exist?(path_to_markdown_file)
        $stdout.puts("File #{path_to_markdown_file} already exists")
      else
        File.write(path_to_markdown_file, Foresite.default_markdown_content(title, time_now.strftime("%F")))
        $stdout.puts("Created file #{path_to_markdown_file}")
      end
    end

    desc "build", "Generates HTML from markdown into `#{Foresite::DIRNAME_OUTPUT}` directory."
    long_desc <<-LONGDESC
      Creates HTML files from all markdown posts and writes them to the `#{Foresite::DIRNAME_OUTPUT}` directory.

      The names of the HTML files should match the names of the markdown files but will use `.html` as the file
      extension instead of `.md`.
    LONGDESC

    def build
      path_to_root_directory = Foresite.get_root_directory
      path_to_markdown_dir = File.join(path_to_root_directory, Foresite::DIRNAME_MARKDOWN)
      path_to_output_dir = File.join(path_to_root_directory, Foresite::DIRNAME_OUTPUT)
      path_to_template_file = File.join(path_to_root_directory, Foresite::FILENAME_TEMPLATE)

      [path_to_markdown_dir, path_to_output_dir].any? do |path|
        unless Dir.exist?(path)
          warn("No `#{Foresite::DIRNAME_MARKDOWN}` directory or `#{Foresite::DIRNAME_OUTPUT}` directory, did you run `foresite init` yet?")
          exit(1)
        end
      end

      # Wipe all output files.
      Dir.glob(File.join(path_to_output_dir, "*")).each { File.delete(_1) }

      markdown_files = Dir.glob(File.join(path_to_markdown_dir, "*.md"))

      if markdown_files.count == 0
        warn("No `.md` files, try running `foresite touch`")
        exit(1)
      end

      links = []
      markdown_files.each do |path_to_markdown|
        markdown_content = File.read(path_to_markdown)

        content = ::Kramdown::Document.new(markdown_content).to_html
        filename_markdown = File.basename(path_to_markdown)
        path_to_html = File.join(path_to_output_dir, filename_markdown.gsub(/\.md$/, ".html"))

        File.write(path_to_html, Foresite::Renderer.render(path_to_template_file, {
          content: content
        }))

        puts "Created file #{path_to_html}"

        title = markdown_content.split("\n").first { |line| /^# [a-z]/i =~ line }.gsub(/^#/, "").strip

        iso_no_space = filename_markdown.split("-").first
        iso_spaces = "#{iso_no_space[0..3]}-#{iso_no_space[4..5]}-#{iso_no_space[6..7]}"

        links.push({
          href: File.basename(path_to_html),
          title: title,
          date: iso_spaces
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
      path_to_index_html = File.join(path_to_output_dir, "index.html")
      File.write(path_to_index_html, Foresite::Renderer.render(path_to_template_file, {
        content: index_content
      }))

      puts "Created file #{path_to_index_html}"
    end
  end
end
