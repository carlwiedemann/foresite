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
      Creates a directory `md` for storing posts, a directory `out` for storing generated output, and a file
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

    desc "touch [TITLE]", "Creates a new `.md` file with TITLE in `md` directory."
    long_desc <<-LONGDESC
      Creates a markdown file for usage as a post, with optional title.

      The name of the file will be the current date suffixed by the `TITLE` argument. The current date will be formatted
      as `YYYYMMDD` and the title will be transformed to use lowercase alphanumeric characters, separated by hyphens.

      Example: (If today is January 14, 2023, and the command is run from /Users/carlos/my_project)

      $ foresite touch "Happy new year!"
      \x5> Created file /Users/carlos/my_project/md/20230114-happy-new-year.md
    LONGDESC

    def touch(title)
      path_to_markdown_directory = File.join(Foresite.get_root_directory, Foresite::DIRNAME_MARKDOWN)

      time_now = Time.now

      base_filename = time_now.strftime('%Y%m%d')
      slug = title.downcase.gsub(/[^a-z]/i, ' ').gsub(/ +/, '-')

      path_to_markdown_file = File.join(path_to_markdown_directory, "#{base_filename}-#{slug}.md")

      if File.exist?(path_to_markdown_file)
        $stdout.puts("File #{path_to_markdown_file} already exists")
      else
        File.write(path_to_markdown_file, Foresite.default_markdown_content(title, time_now.strftime('%F')))
        $stdout.puts("Created file #{path_to_markdown_file}")
      end
    end
  end
end
