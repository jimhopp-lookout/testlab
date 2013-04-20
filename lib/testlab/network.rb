class TestLab

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Network < ZTK::DSL::Base
    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :cidr
    attribute   :config

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

    # Create the network
    def create
      @ui.logger.debug { "Network Create: #{self.id} " }
    end

    # Destroy the network
    def destroy
      @ui.logger.debug { "Network Destroy: #{self.id} " }
    end

    # Start the network
    def up
      @ui.logger.debug { "Network Up: #{self.id} " }
    end

    # Stop the network
    def down
      @ui.logger.debug { "Network Down: #{self.id} " }
    end

    # Reload the network
    def reload
      self.down
      self.up
    end

    # State of the network
    def state
    end

    # Network Callback: after_up
    def after_up
      @ui.logger.debug { "Network Callback: After Up: #{self.id} " }
      self.create
      self.up
    end

    # Network Callback: before_down
    def before_down
      @ui.logger.debug { "Network Callback: Before Down: #{self.id} " }
      self.down
    end

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "NETWORK METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }
      super(method_name, *method_args)
    end

  end

end
