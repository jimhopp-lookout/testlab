class TestLab
  class Container

    module Configuration

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

      # LXC Container Configuration
      #
      # Builds the LXC container configuration data.
      #
      # @return [Boolean] True if successful.
      def build_lxc_config(lxc_config)
        lxc_config.clear

        lxc_config['lxc.arch']    = self.arch
        lxc_config['lxc.utsname'] = self.fqdn

        unless self.aa_profile.nil?
          lxc_config['lxc.aa_profile'] = self.aa_profile
        end

        unless self.cap_drop.nil?
          lxc_config['lxc.cap.drop'] = [self.cap_drop].flatten.compact.map(&:downcase).join(' ')
        end

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
          if (self.primary_interface == interface)
            networks.last.merge!('lxc.network.ipv4.gateway' => :auto)
          end
        end

        networks
      end

    end

  end
end
