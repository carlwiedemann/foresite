module Foresite
  class Cli < ::Thor

    desc "pluralize", "Pluralizes a word"
    method_option :word, aliases: "-w"

    def pluralize(name)
      puts "hello"
    end

    desc "say_hello NAME", "say hello to NAME"

    def say_hello(name)
      puts "Hello #{name}"
    end

  end
end
