class TestLab

  # Dependency Error Class
  class DependencyError < TestLabError; end

  # Dependency Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Dependency < ZTK::DSL::Base
    # Associations and Attributes
    belongs_to :labfile,       :class_name => 'TestLab::Labfile'

    def initialize(*args)
      @ui = TestLab.ui

      @ui.logger.info { "Loading Dependency '#{self.id}'" }
      super(*args)
      @ui.logger.info { "Dependency '#{self.id}' Loaded" }
    end

  end

end
