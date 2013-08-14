class TestLab
  class Network

    module Status

      # Network status
      def status
        interface = "#{bridge}:#{self.address}"
        {
          :id => self.id,
          :node_id => self.node.id,
          :state => self.state,
          :interface => interface,
          :broadcast => self.broadcast,
          :network => self.network,
          :netmask => self.netmask,
          :provisioners => self.provisioners.map(&:to_s).collect{ |p| p.split('::').last }.join(','),
        }
      end

      # Debian Network 'interfaces' Start Definition Tag
      def def_tag
        "#TESTLAB-DEF-#{self.bridge.to_s.upcase}"
      end

      # Debian Network 'interfaces' End Definition Tag
      def end_tag
        "#TESTLAB-END-#{self.bridge.to_s.upcase}"
      end

      # Network IP
      #
      # Returns the IP of the network bridge.
      #
      # @return [String] The network bridge IP address.
      def ip
        TestLab::Utility.ip(self.address)
      end

      # Network CIDR
      #
      # Returns the CIDR of the network bridge.
      #
      # @return [Integer] The network bridge CIDR address.
      def cidr
        TestLab::Utility.cidr(self.address)
      end

      # Returns the network mask
      def netmask
        TestLab::Utility.netmask(self.address)
      end

      # Returns the network address
      def network
        TestLab::Utility.network(self.address)
      end

      # Returns the broadcast address
      def broadcast
        TestLab::Utility.broadcast(self.address)
      end

      # Network Bridge State
      def state
        if self.node.dead?
          :unknown
        else
          exit_code = self.node.exec(%(sudo brctl show #{self.bridge} 2>&1 | grep -i 'No such device'), :ignore_exit_status => true).exit_code
          if (exit_code == 0)
            :not_created
          else
            output = self.node.exec(%(sudo ifconfig #{self.bridge} 2>&1 | grep 'MTU'), :ignore_exit_status => true).output
            if ((output =~ /UP/) || (output =~ /RUNNING/))
              :running
            else
              :stopped
            end
          end
        end
      end

    end

  end
end
