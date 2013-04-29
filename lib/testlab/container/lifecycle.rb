class TestLab
  class Container

    module Lifecycle

      # Container Setup
      def setup
        @ui.logger.debug { "Container Setup: #{self.id} " }

        self.create
        self.up

        if (!@provisioner.nil? && @provisioner.respond_to?(:setup))
          @provisioner.setup(self)
        end

        true
      end

      # Container Teardown
      def teardown
        @ui.logger.debug { "Container Teardown: #{self.id} " }

        if (!@provisioner.nil? && @provisioner.respond_to?(:teardown))
          @provisioner.teardown(self)
        end

        self.down
        self.destroy

        true
      end

    end

  end
end
