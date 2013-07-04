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

        (self.node.state != :running) and return false
        (self.lxc.state == :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          self.container_provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> CONTAINER PROVISIONER SETUP: #{provisioner} (#{self.id}) <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_container_setup) and p.on_container_setup(self)
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
        (self.lxc.state == :not_created) and return false

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
        self.setup

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
        [self.interfaces.map(&:network).map(&:provisioners), self.provisioners].flatten.compact.uniq
      end

    end

  end
end
