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

      # Returns arguments for lxc-create based on our distro
      #
      # @return [Array<String>] An array of arguments for lxc-create
      def create_args
        case self.distro.downcase
        when "ubuntu" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release} --arch #{self.arch})
        when "fedora" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release})
        end
      end

      # Attempt to detect the architecture of the node.  The value returned is
      # respective to the container distro.
      #
      # @return [String] The arch of the node in the context of the container
      #   distro
      def detect_arch
        case self.distro.downcase
        when "ubuntu" then
          ((self.node.arch =~ /x86_64/) ? "amd64" : "i386")
        when "fedora" then
          ((self.node.arch =~ /x86_64/) ? "amd64" : "i686")
        end
      end

    end

  end
end
