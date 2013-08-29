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

        self.node.alive? or return false

        persistent_operation_check(:create)

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

        self.node.alive? or return false

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

        self.node.alive? or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          configure

          # Remove any existing ARP entries for our container from the node.
          self.interfaces.each do |interface|
            self.node.exec(%(sudo arp --verbose --delete #{interface.ip}), :ignore_exit_status => true)
          end

          if self.is_ephemeral?
            self.lxc_clone.start_ephemeral(clone_args)
          else
            self.lxc.start(start_args)
          end

          (self.state != :running) and raise ContainerError, "The container failed to online! (did you create it? Check status with 'tl status')"

          ZTK::TCPSocketCheck.new(:ui => @ui, :host => self.primary_interface.ip, :port => 22).wait

          # If we are not in ephemeral mode we should attempt to provision our
          # defined users.
          if self.is_persistent?
            self.users.each do |user|
              user.provision
            end
          end

          # Ensure the hostname is set
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

        self.node.alive? or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do

          self.lxc.stop

          # If we are in ephemeral mode...
          if self.is_ephemeral?

            # IMPORTANT NOTE:
            #
            # If we are using a non-memory backed COW filesystem for the
            # ephemeral clones we should destroy the container.
            #
            # If we are using a memory backed COW filesystem for the ephemeral
            # clones then it will be released when the container is stopped.
            self.persist and self.lxc.destroy(%(-f))
          end

          (self.state == :running) and raise ContainerError, "The container failed to offline!"

          do_provisioner_callbacks(self, :down, @ui)
        end

        true
      end

    end

  end
end
