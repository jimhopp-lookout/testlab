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
    attribute  :version, :default => TestLab::VERSION

    def initialize(*args)
      @ui = TestLab.ui

      @ui.logger.info { "Loading Labfile '#{self.id}'" }
      super(*args)
      @ui.logger.info { "Labfile '#{self.id}' Loaded" }
    end

    def config_dir
      self.testlab.config_dir
    end

    def repo_dir
      self.testlab.repo_dir
    end

  end

end
