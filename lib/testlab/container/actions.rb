class TestLab
  class Container

    module Actions

      # Create the container
      def create
        @ui.logger.debug { "Container Create: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          self.domain  ||= self.node.labfile.config[:domain]
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
      end

      # Destroy the container
      def destroy
        @ui.logger.debug { "Container Destroy: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.lxc.destroy
        end
      end

      # Start the container
      def up
        @ui.logger.debug { "Container Up: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          self.lxc.start
          self.lxc.wait(:running)
        end
      end

      # Stop the container
      def down
        @ui.logger.debug { "Container Down: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.lxc.stop
          self.lxc.wait(:stopped)
        end
      end

    end

  end
end
