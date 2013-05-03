class TestLab
  class Container

    module Lifecycle

      # Setup the container
      #
      # Attempts to setup the container.  We first create the container, then
      # attempt to bring it online.  Afterwards the containers provisioner is
      # called.
      #
      # @return [Boolean] True if successful.
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

      # Teardown the container
      #
      # Attempts to teardown the container.  We first call the provisioner
      # teardown method defined for the container, if any.  Next we attempt to
      # offline the container.  Afterwards the container is destroy.
      #
      # @return [Boolean] True if successful.
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
