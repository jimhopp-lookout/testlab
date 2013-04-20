class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :links

    attribute   :config
    attribute   :provisioner

    attribute   :name
    attribute   :ip
    attribute   :mac
    attribute   :persist
    attribute   :distro
    attribute   :release
    attribute   :arch

    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config) if !self.provisioner.nil?
    end

    # Create the container
    def create
      @ui.logger.debug { "Container Create: #{self.id} " }
    end

    # Destroy the container
    def destroy
      @ui.logger.debug { "Container Destroy: #{self.id} " }
    end

    # Start the container
    def up
      @ui.logger.debug { "Container Up: #{self.id} " }
    end

    # Stop the container
    def down
      @ui.logger.debug { "Container Down: #{self.id} " }
    end

    # Reload the container
    def reload
      self.down
      self.up
    end

    # State of the container
    def state
    end

    # Container Callback: after_up
    def after_up
      @ui.logger.debug { "Container Callback: After Up: #{self.id} " }
      self.create
      self.up
    end

    # Container Callback: before_down
    def before_down
      @ui.logger.debug { "Container Callback: Before Down: #{self.id} " }
      self.down
    end

    def method_missing(method_name, *method_args)
      if (defined?(@provisioner) && @provisioner.respond_to?(method_name))
        @provisioner.send(method_name, [self, *method_args].flatten)
      else
        super(method_name, *method_args)
      end
    end

  end

end
