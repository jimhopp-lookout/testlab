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

      # LXC::Container object
      #
      # Returns a *LXC::Container* class instance configured for the clone of
      # this container.
      #
      # @return [LXC] An instance of LXC::Container configured for the clone of
      #   this container.
      def lxc_clone
        @lxc_clone ||= self.node.lxc.container("#{self.id}-master")
      end

      # Convert to Static Container
      #
      # If the current container is operating as an ephemeral container, this
      # will convert it back to a static container, otherwise no changes will
      # occur.
      #
      # @return [Boolean] Returns true if successful.
      def to_static
        if self.lxc_clone.exists?
          self.lxc.stop
          self.lxc.destroy(%(-f))

          self.lxc_clone.stop
          self.lxc_clone.clone(%W(-o #{self.lxc_clone.name} -n #{self.lxc.name}))
          self.lxc_clone.destroy(%(-f))

          build_lxc_config(self.lxc.config)
        end

        true
      end

      # Convert to Ephemeral Container
      #
      # If the current container is operating as a static container, this will
      # convert it to a ephemeral container, otherwise no changes will occur.
      #
      # @return [Boolean] Returns true if successful.
      def to_ephemeral
        if (self.lxc.exists? && !self.lxc_clone.exists?)
          self.lxc_clone.stop
          self.lxc_clone.destroy(%(-f))

          self.lxc.stop
          self.lxc.clone(%W(-o #{self.lxc.name} -n #{self.lxc_clone.name}))
          self.lxc.destroy(%(-f))

          build_lxc_config(self.lxc_clone.config)
        else
          self.lxc.stop
          self.persist and self.lxc.destroy(%(-f))
        end

        true
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

      # LXC Container Configuration
      #
      # Builds the LXC container configuration data.
      #
      # @return [Boolean] True if successful.
      def build_lxc_config(lxc_config)
        lxc_config.clear

        lxc_config['lxc.arch']    = self.arch
        lxc_config['lxc.utsname'] = self.fqdn
        lxc_config.networks       = build_lxc_network_conf(self.interfaces)

        lxc_config.save

        true
      end

      # LXC Network Configuration
      #
      # Builds an array of hashes containing the lxc configuration options for
      # our network interfaces.
      #
      # @return [Array<Hash>] An array of hashes defining the containers
      #   interfaces for use in configuring LXC.
      def build_lxc_network_conf(interfaces)
        networks = Array.new

        interfaces.each do |interface|
          networks << Hash[
            'lxc.network.type'   => :veth,
            'lxc.network.flags'  => :up,
            'lxc.network.link'   => interface.network.bridge,
            'lxc.network.name'   => interface.name,
            'lxc.network.hwaddr' => interface.mac,
            'lxc.network.ipv4'   => "#{interface.ip}/#{interface.cidr} #{interface.netmask}"
          ]
          if (interface.primary == true) || (interfaces.count == 1)
            networks.last.merge!('lxc.network.ipv4.gateway' => :auto)
          end
        end

        networks
      end

    end

  end
end
