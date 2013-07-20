class TestLab
  class Container

    module LXC

      # Container Console
      #
      # Opens an LXC console into the container.
      #
      # This command will replace the current process with an SSH session that
      # will execute the appropriate LXC console command on the parent node of
      # this container.
      def console
        @ui.stdout.puts("Press CTRL-A Q to exit the console.  (CTRL-A CTRL-A to enter a CTRL-A itself)".red.bold)
        self.node.ssh.console(%(-t 'sudo lxc-console -n #{self.id}'))
      end

      # LXC::Container object
      #
      # Returns a *LXC::Container* class instance configured for this container.
      #
      # @return [LXC] An instance of LXC::Container configured for this
      #   container.
      def lxc
        @lxc ||= self.node.lxc.container(self.id)
      end

      # Does the container exist?
      #
      # @return [Boolean] True if the containers exists, false otherwise.
      def exists?
        @ui.logger.debug { "Container Exists?: #{self.id} " }

        self.lxc.exists?
      end

      # Container root filesystem path
      #
      # @return [String] The path to the containers root filesystem.
      def fs_root
        self.lxc.fs_root(self.lxc_clone.exists?)
      end

    end

  end
end
