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

      def ip
        TestLab::Utility.ip(self.address)
      end

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
        exit_code = self.node.ssh.exec(%(sudo brctl show #{self.bridge} 2>&1 | grep -i 'No such device'), :silence => true, :ignore_exit_status => true).exit_code
        if (exit_code == 0)
          :not_created
        else
          output = self.node.ssh.exec(%(sudo ifconfig #{self.bridge} 2>&1 | grep 'MTU'), :silence => true, :ignore_exit_status => true).output.strip
          if ((output =~ /UP/) && (output =~ /RUNNING/))
            :running
          else
            :stopped
          end
        end
      end

    end

  end
end
