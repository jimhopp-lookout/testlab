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
        @ui.logger.debug { "Container Create: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          self.domain  ||= self.node.labfile.config[:domain]
          self.arch    ||= detect_arch

          build_lxc_config(self.lxc.config)

          self.lxc.create(*create_args)

          # TODO: This needs to really go somewhere else:
          home_dir = ((self.node.user == "root") ? %(/root) : %(/home/#{self.node.user}))
          container_home_dir = File.join(self.lxc.fs_root, "/home/ubuntu")

          home_authkeys = File.join(home_dir, ".ssh", "authorized_keys")
          container_authkeys = File.join(container_home_dir, ".ssh", "authorized_keys")
          container_authkeys2 = File.join(container_home_dir, ".ssh", "authorized_keys2")

          authkeys = {
            home_authkeys => container_authkeys,
            home_authkeys => container_authkeys2
          }

          self.node.ssh.exec(%(mkdir -pv #{File.join(container_home_dir, %(.ssh))}))
          authkeys.each do |source, destination|
            self.node.ssh.exec(%(sudo cp -v #{source} #{destination}))
            self.node.ssh.exec(%(sudo chown -v 1000:1000 #{destination}))
            self.node.ssh.exec(%(sudo chmod -v 644 #{destination}))
          end

        end

        true
      end

      # Destroy the container
      #
      # Sends a request to the LXC sub-system to destroy the container.
      #
      # @return [Boolean] True if successful.
      def destroy
        @ui.logger.debug { "Container Destroy: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.lxc.destroy(%(-f))
          self.lxc_clone.destroy(%(-f))
        end

        true
      end

      # Start the container
      #
      # Sends a request to the LXC sub-system to bring the container online.
      #
      # @return [Boolean] True if successful.
      def up
        @ui.logger.debug { "Container Up: #{self.id} " }

        (self.lxc.state == :not_created) and return false #raise ContainerError, "We can not online a non-existant container!"

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do

          # ensure our container is in "static" mode
          self.to_static

          self.lxc.start
          self.lxc.wait(:running)

          (self.lxc.state != :running) and raise ContainerError, "The container failed to online!"

          # TODO: This needs to really go somewhere else:
          self.lxc.attach(%(-- /bin/bash -c 'grep "sudo\tALL=\(ALL:ALL\) ALL" /etc/sudoers && sed -i "s/sudo\tALL=\(ALL:ALL\) ALL/sudo\tALL=\(ALL:ALL\) NOPASSWD: ALL/" /etc/sudoers'))
        end

        true
      end

      # Stop the container
      #
      # Sends a request to the LXC sub-system to take the container offline.
      #
      # @return [Boolean] True if successful.
      def down
        @ui.logger.debug { "Container Down: #{self.id} " }

        (self.lxc.state == :not_created) and return false # raise ContainerError, "We can not offline a non-existant container!"

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.lxc.stop
          self.lxc.wait(:stopped)

          (self.lxc.state == :running) and raise ContainerError, "The container failed to offline!"
        end

        true
      end

      # Clone the contaienr
      #
      # Prepares the container, if needed, for ephemeral cloning and clones it.
      #
      # @return [Boolean] True if successful.
      def clone
        @ui.logger.debug { "Container Clone: #{self.id}" }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Clone', :yellow)) do

          # ensure our container is in "ephemeral" mode
          self.to_ephemeral

          self.node.ssh.exec(%(sudo arp --verbose --delete #{self.ip}), :ignore_exit_status => true)
          self.lxc_clone.start_ephemeral(%W(-o #{self.lxc_clone.name} -n #{self.lxc.name} -d))
        end

        true
      end

    end

  end
end
