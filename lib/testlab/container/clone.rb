class TestLab
  class Container

    module Clone

      # Clone the container
      #
      # Prepares the container, if needed, for ephemeral cloning and clones it.
      #
      # @return [Boolean] True if successful.
      def clone
        @ui.logger.debug { "Container Clone: #{self.id}" }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Clone', :yellow)) do

          # ensure our container is in "ephemeral" mode
          self.to_ephemeral

          self.node.exec(%(sudo arp --verbose --delete #{self.ip}), :ignore_exit_status => true)

          ephemeral_arguments = Array.new
          ephemeral_arguments << %W(-o #{self.lxc_clone.name} -n #{self.lxc.name} -d)
          ephemeral_arguments << %W(--keep-data) if self.persist
          ephemeral_arguments.flatten!.compact!

          self.lxc_clone.start_ephemeral(ephemeral_arguments)
        end

        true
      end

      # Configure the container
      #
      # Configures the LXC subsystem for the container.
      #
      # @return [Boolean] True if successful.
      def configure
        self.domain ||= self.node.domain
        self.arch   ||= detect_arch

        build_lxc_config(self.lxc.config)

        true
      end

    end

  end
end
