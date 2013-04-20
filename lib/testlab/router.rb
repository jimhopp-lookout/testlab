class TestLab

  # Router Error Class
  class RouterError < TestLabError; end

  # Router Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Router < ZTK::DSL::Base
    belongs_to  :node,        :class_name => 'TestNode::Node'

    attribute   :interfaces

    def initialize(*args)
      super(*args)

      @ui = TestLab.ui
    end

    # Create the router
    def create
      @ui.logger.debug { "Router Create: #{self.id} " }
    end

    # Destroy the router
    def destroy
      @ui.logger.debug { "Router Destroy: #{self.id} " }
    end

    # Start the router
    def up
      @ui.logger.debug { "Router Up: #{self.id} " }
    end

    # Stop the router
    def down
      @ui.logger.debug { "Router Down: #{self.id} " }
    end

    # Reload the router
    def reload
      self.down
      self.up
    end

    # State of the router
    def state
    end

    # Router Callback: after_up
    def after_up
      @ui.logger.debug { "Router Callback: After Up: #{self.id} " }
      self.create
      self.up
    end

    # Router Callback: before_down
    def before_down
      @ui.logger.debug { "Router Callback: Before Down: #{self.id} " }
      self.down
    end

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "ROUTER METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }
      super(method_name, *method_args)
    end

  end

end
