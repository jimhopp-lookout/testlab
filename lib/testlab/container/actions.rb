class TestLab
  class Container

    module Actions

      # Create the container
      #
      # Builds the configuration for the container and sends a request to the
      # LXC sub-system to create the container.
      #
      # @return [Boolean] True if successful.
      def create
        @ui.logger.debug { "Container Create: #{self.id}" }

        (self.node.state != :running) and return false
        (self.lxc.state != :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          configure

          self.lxc.create(*create_args)

          do_provisioner_callbacks(self, :create, @ui)
        end

        true
      end

      # Destroy the container
      #
      # Sends a request to the LXC sub-system to destroy the container.
      #
      # @return [Boolean] True if successful.
      def destroy
        @ui.logger.debug { "Container Destroy: #{self.id}" }

        (self.node.state != :running) and return false
        (self.lxc.state == :not_created) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.lxc.destroy(%(-f))
          self.lxc_clone.destroy(%(-f))

          do_provisioner_callbacks(self, :destroy, @ui)
        end

        true
      end

      # Start the container
      #
      # Sends a request to the LXC sub-system to bring the container online.
      #
      # @return [Boolean] True if successful.
      def up
        @ui.logger.debug { "Container Up: #{self.id}" }

        (self.node.state != :running) and return false
        (self.lxc.state == :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          configure

          # ensure our container is in "static" mode
          self.to_static

          self.lxc.start(%(--daemon))

          (self.lxc.state != :running) and raise ContainerError, "The container failed to online!"

          self.users.each do |user|
            user.provision
          end

          self.exec(%(sudo hostname #{self.fqdn}))

          do_provisioner_callbacks(self, :up, @ui)
        end

        true
      end

      # Stop the container
      #
      # Sends a request to the LXC sub-system to take the container offline.
      #
      # @return [Boolean] True if successful.
      def down
        @ui.logger.debug { "Container Down: #{self.id}" }

        (self.node.state != :running) and return false
        (self.lxc.state != :running) and return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.lxc.stop

          (self.lxc.state == :running) and raise ContainerError, "The container failed to offline!"

          do_provisioner_callbacks(self, :down, @ui)
        end

        true
      end

    end

  end
end
