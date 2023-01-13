module Foresite
  class Cli < ::Thor

    desc "say_hello NAME", "say hello to NAME"

    def say_hello(name)
      puts "Hello #{name}"
    end

  end
end
