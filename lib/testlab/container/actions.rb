class TestLab
  class Container

    module Actions

      # Create the container
      def create
        @ui.logger.debug { "Container Create: #{self.id} " }

        self.distro  ||= "ubuntu"
        self.release ||= "precise"
        self.arch    ||= detect_arch

        self.lxc.config.clear
        self.lxc.config['lxc.utsname'] = self.id
        self.lxc.config['lxc.arch'] = self.arch
        self.lxc.config.networks = build_lxc_network_conf(self.interfaces)
        self.lxc.config.save

        self.lxc.create(*create_args)
      end

      # Destroy the container
      def destroy
        @ui.logger.debug { "Container Destroy: #{self.id} " }

        self.lxc.destroy
      end

      # Start the container
      def up
        @ui.logger.debug { "Container Up: #{self.id} " }

        self.lxc.start
      end

      # Stop the container
      def down
        @ui.logger.debug { "Container Down: #{self.id} " }

        self.lxc.stop
      end

    end

  end
end
