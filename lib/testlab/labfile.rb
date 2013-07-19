class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Labfile < ZTK::DSL::Base
    has_many   :nodes,   :class_name => 'TestLab::Node'

    attribute  :testlab
    attribute  :config,  :default => Hash.new

    def config_dir
      self.testlab.config_dir
    end

    def repo_dir
      self.testlab.repo_dir
    end

  end

end
