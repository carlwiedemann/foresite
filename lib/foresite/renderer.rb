module Foresite
  class Renderer
    def initialize(path, vars)
      @path = path
      vars.each do |k, v|
        if k.is_a?(Symbol)
          instance_variable_set("@#{k}".to_sym, v)
        end
      end
    end

    def render
      ::ERB.new(File.read(@path)).result(binding)
    end

    def self.render(path, vars)
      new(path, vars).render
    end
  end
end