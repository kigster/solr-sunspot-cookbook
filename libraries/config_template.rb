module Solr
  class ConfigTemplate
    attr_reader :name, :source_cookbook, :core_directory, :source_template, :template_mode, :template_variables

    def initialize(name, core_directory, &blk)
      @name = name
      @core_directory = core_directory
      @template_mode = 0644
      @template_variables = {}
      instance_eval(&blk)
    end

    def source(source)
      @source_template = source
    end

    def cookbook(cookbook)
      @source_cookbook = cookbook
    end

    def variables(variables)
      @template_variables = variables
    end

    def mode(mode)
      @template_mode = mode
    end

    ## Helpers

    def path
      '%s/conf/%s' % [core_directory, name]
    end
  end
end
