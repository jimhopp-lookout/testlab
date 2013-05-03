class TestLab
  class Container

    module Status

      # Container IP
      #
      # Returns the IP of the container
      def ip
        TestLab::Utility.ip(self.primary_interface.address)
      end

      # Container CIDR
      #
      # Returns the CIDR of the container
      def cidr
        TestLab::Utility.cidr(self.primary_interface.address).to_i
      end

      # Container BIND PTR Record
      #
      # Returns a BIND PTR record
      def ptr
        TestLab::Utility.ptr(self.primary_interface.address)
      end

      # Container FQDN
      #
      # Returns the FQDN for the container
      def fqdn
        self.domain ||= self.node.labfile.config[:domain]

        [self.id, self.domain].join('.')
      end

      # Container Status
      #
      # Returns a hash of status information for the container
      def status
        interfaces = self.interfaces.collect do |interface|
          "#{interface.network_id}:#{interface.name}:#{interface.ip}/#{interface.cidr}"
        end.join(', ')

        {
          :id => self.id,
          :fqdn => self.fqdn,
          :state => self.state,
          :distro => self.distro,
          :release => self.release,
          :interfaces => interfaces,
          :provisioner => self.provisioner,
          :node_id => self.node.id
        }
      end

      # Container State
      #
      # What state the container is in.
      def state
        self.lxc.state
      end

    end

  end
end
