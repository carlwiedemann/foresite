module Foresite
  ##
  # Renderer class.
  #
  # Basic implementation of ERB for a path to a given template and variables.
  #
  class Renderer
    ##
    # Constructor.
    #
    # @param [String] path Path to file.
    # @param [Hash] vars Variables for template.
    def initialize(path, vars)
      @path = path
      vars.each do |k, v|
        if k.is_a?(Symbol)
          instance_variable_set("@#{k}".to_sym, v)
        end
      end
    end

    ##
    # Renders template with variables.
    #
    # @return [String] Rendered template output.
    #
    def render
      ::ERB.new(File.read(@path)).result(binding)
    end

    ##
    # Statically renders template with variables.
    #
    # @param [String] path Path to file.
    # @param [Hash] vars Variables for template.
    #
    # @return [String] Rendered template output.
    #
    def self.render(path, vars)
      new(path, vars).render
    end
  end
end
