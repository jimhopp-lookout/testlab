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

        please_wait(:ui => @ui, :message => format_object_action(self, 'Provision', :green)) do

          self.container_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> CONTAINER PROVISIONER: #{provisioner} (#{self.id}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_container_provision) and p.on_container_provision(self)
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

        (self.node.state != :running) and return false
        (self.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          self.container_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> CONTAINER PROVISIONER TEARDOWN: #{provisioner} (#{self.id}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_container_teardown) and p.on_container_teardown(self)
          end

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
        self.teardown
        self.down
        self.destroy

        true
      end

      # Returns all defined provisioners for this container's networks and the container iteself.
      def container_provisioners
        [self.node.provisioners, self.interfaces.map(&:network).map(&:provisioners), self.provisioners].flatten.compact.uniq
      end

    end

  end
end
