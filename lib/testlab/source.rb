class TestLab

  # Source Error Class
  class SourceError < TestLabError; end

  # Source Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Source < ZTK::DSL::Base
    # Associations and Attributes
    belongs_to :labfile,       :class_name => 'TestLab::Labfile'

    def initialize(*args)
      @ui = TestLab.ui

      @ui.logger.info { "Loading Source '#{self.id}'" }
      super(*args)
      @ui.logger.info { "Source '#{self.id}' Loaded" }
    end

  end

end
