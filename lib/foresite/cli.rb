module Foresite
  class Cli < ::Thor

    desc "pluralize", "Pluralizes a word"
    method_option :word, aliases: "-w"
    def pluralize(name)
      puts "hello"
    end

  end
end