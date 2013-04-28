class TestLab
  class Container

    module LXC

      # Our LXC Container class
      #
      # @return [LXC] An instance of LXC::Container configured for this
      #   container.
      def lxc
        @lxc ||= self.node.lxc.container(self.id)
      end

      # Does the container exist?
      def exists?
        @ui.logger.debug { "Container Exists?: #{self.id} " }

        self.lxc.exists?
      end

      # Returns arguments for lxc-create based on our distro
      #
      # @return [Array] An array of arguments for lxc-create
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

      # Builds an array of hashes containing the lxc configuration options for
      # our networks
      def build_lxc_network_conf(interfaces)
        networks = Array.new

        interfaces.each do |network, network_config|
          networks << Hash[
            'lxc.network.type'         => :veth,
            'lxc.network.flags'        => :up,
            'lxc.network.link'         => TestLab::Network.first(network).bridge,
            'lxc.network.name'         => network_config[:name],
            'lxc.network.hwaddr'       => network_config[:mac],
            'lxc.network.ipv4'         => network_config[:ip]
          ]
          if (network_config[:primary] == true) || (interfaces.count == 1)
            networks.last.merge!('lxc.network.ipv4.gateway' => :auto)
          end
        end

        networks
      end

    end

  end
end
