class TestLab
  class Container

    module Lifecycle

      # Provision the container
      #
      # Attempts to provision the container.  We first create the container,
      # then attempt to bring it online.  Afterwards the containers provisioner
      # is called.
      #
      # @return [Boolean] True if successful.
      def provision
        @ui.logger.debug { "Container Provision: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, :provision, :green)) do
          do_provisioner_callbacks(self, :provision, @ui)
        end

        true
      end

      # Deprovision the container
      #
      # Attempts to deprovision the container.  We first call the provisioner
      # deprovision method defined for the container, if any.  Next we attempt
      # to offline the container.  Afterwards the container is destroy.
      #
      # @return [Boolean] True if successful.
      def deprovision
        @ui.logger.debug { "Container Deprovision: #{self.id} " }

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, :deprovision, :red)) do
          do_provisioner_callbacks(self, :deprovision, @ui)
        end

        true
      end

      # Build the container
      def build
        self.create
        self.up
        self.provision

        true
      end

      # Demolish the container
      def demolish
        self.deprovision
        self.down
        self.destroy

        true
      end

    end

  end
end
