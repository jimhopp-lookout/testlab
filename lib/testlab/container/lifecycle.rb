class TestLab
  class Container

    module Lifecycle

      # Container Setup
      def setup
        @ui.logger.debug { "Container Setup: #{self.id} " }

        self.create
        self.up
      end

      # Container Teardown
      def teardown
        @ui.logger.debug { "Container Teardown: #{self.id} " }

        self.down
        self.destroy
      end

    end

  end
end
