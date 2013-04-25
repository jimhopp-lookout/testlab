class TestLab
  class Container

    module Callbacks

      # Container Callback: after_create
      def after_create
        @ui.logger.debug { "Container Callback: After Create: #{self.id} " }
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
        self.destroy
      end

      # Container Callback: before_destroy
      def before_destroy
        @ui.logger.debug { "Container Callback: Before Destroy: #{self.id} " }
      end

    end

  end
end
