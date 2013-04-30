class TestLab
  class Container

    module Lifecycle

      # Container Setup
      def setup
        @ui.logger.debug { "Container Setup: #{self.id} " }

        self.create
        self.up

        if (!@provisioner.nil? && @provisioner.respond_to?(:setup))
          please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do
            @provisioner.setup(self)
          end
        end

        true
      end

      # Container Teardown
      def teardown
        @ui.logger.debug { "Container Teardown: #{self.id} " }

        if (!@provisioner.nil? && @provisioner.respond_to?(:teardown))
          please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do
            @provisioner.teardown(self)
          end
        end

        self.down
        self.destroy

        true
      end

    end

  end
end
