class TestLab
  class Network

    module Status

      # Network status
      def status
        interface = "#{bridge}:#{ip}"
        {
          :id => self.id,
          :node_id => self.node.id,
          :state => self.state,
          :interface => interface,
          :broadcast => self.broadcast,
          :network => self.network,
          :netmask => self.netmask
        }
      end

      # Returns the network mask
      def netmask
        TestLab::Utility.netmask(self.ip)
      end

      # Returns the network address
      def network
        TestLab::Utility.network(self.ip)
      end

      # Returns the broadcast address
      def broadcast
        TestLab::Utility.broadcast(self.ip)
      end

      # Network Bridge State
      def state
        output = self.node.ssh.exec(%(sudo ifconfig #{self.bridge} | grep 'MTU'), :silence => true, :ignore_exit_status => true).output.strip
        if ((output =~ /UP/) && (output =~ /RUNNING/))
          :running
        else
          :stopped
        end
      end

    end

  end
end
