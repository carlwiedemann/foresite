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

    desc "init [-d=/path/to/dir]", "Creates md directory and template in current directory or in `-d` (optional)."
    method_options d: :string

    def init
      directory_name = options.d || Dir.pwd

      if Dir.exist?(directory_name)
        # pp directory_name
      else
        warn("Nonexistent directory #{directory_name}")
        exit 1
      end
    end
  end
end
