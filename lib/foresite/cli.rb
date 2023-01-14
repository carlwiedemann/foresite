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

    desc "init [-d=/path/to/dir]", "Creates `md` directory and template in current directory or in `-d` (optional)."
    method_options d: :string

    def init
      directory_name = options.d || Dir.pwd

      if Dir.exist?(directory_name)
        if File.writable?(directory_name)
          # Create markdown directory.
          path_to_markdown_dir = File.join(directory_name, Foresite::DIRNAME_MARKDOWN)
          if Dir.exist?(path_to_markdown_dir)
            $stdout.puts("Directory #{path_to_markdown_dir} already exists")
          else
            Dir.mkdir(path_to_markdown_dir)
            $stdout.puts("Created directory #{path_to_markdown_dir}")
          end

          # Create output directory.
          path_to_output_dir = File.join(directory_name, Foresite::DIRNAME_OUTPUT)
          if Dir.exist?(path_to_output_dir)
            $stdout.puts("Directory #{path_to_output_dir} already exists")
          else
            Dir.mkdir(path_to_output_dir)
            $stdout.puts("Created directory #{path_to_output_dir}")
          end

          # Create base template.
          path_to_template = File.join(directory_name, Foresite::FILENAME_TEMPLATE)
          if File.exist?(path_to_template)
            $stdout.puts("File #{path_to_template} already exists")
          else
            File.copy_stream(Foresite::PATH_TO_SAMPLE_TEMPLATE, path_to_template)
            $stdout.puts("Created file #{path_to_template}")
          end
        else
          warn("Cannot write to directory #{directory_name}")
          exit(1)
        end
      else
        warn("Nonexistent directory #{directory_name}")
        exit(1)
      end
    end
  end
end
