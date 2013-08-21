class TestLab

  # Labfile Error Class
  class LabfileError < TestLabError; end

  # Labfile Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Labfile < ZTK::DSL::Base
    has_many   :dependencies,  :class_name => 'TestLab::Dependency'
    has_many   :sources,       :class_name => 'TestLab::Source'
    has_many   :nodes,         :class_name => 'TestLab::Node'

    attribute  :testlab
    attribute  :config,        :default => Hash.new
    attribute  :version

    def initialize(*args)
      @ui = TestLab.ui

      @ui.logger.debug { "Loading Labfile" }
      super(*args)
      @ui.logger.debug { "Labfile '#{self.id}' Loaded" }

      if version.nil?
        raise LabfileError, 'You must version the Labfile!'
      else
        @ui.logger.debug { "Labfile Version: #{version}" }
        version_arguments = version.split
        @ui.logger.debug { version_arguments.inspect }

        if version_arguments.count == 1
          if (TestLab::VERSION != version_arguments.first)
            raise LabfileError, 'Your Labfile is not compatible with this Version of TestLab!'
          end
        elsif version_arguments.count == 2
          if !TestLab::VERSION.send(version_arguments.first, version_arguments.last)
            raise LabfileError, 'Your Labfile is not compatible with this Version of TestLab!'
          end
        else
          raise LabfileError, 'Invalid version!'
        end
      end
    end

    def config_dir
      self.testlab.config_dir
    end

    def repo_dir
      self.testlab.repo_dir
    end

  end

end
