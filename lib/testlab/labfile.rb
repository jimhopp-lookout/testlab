class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Labfile < ZTK::DSL::Base
    attribute  :testlab
    has_many   :nodes,   :class_name => 'TestLab::Node'

    attribute  :config,  :default => Hash.new

    def config_dir
      self.testlab.config_dir
    end

  end

end
