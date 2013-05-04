class TestLab
  class Container

    module Status

      # Container IP
      #
      # Returns the IP of the container.
      #
      # @return [String] The containers IP address.
      def ip
        TestLab::Utility.ip(self.primary_interface.address)
      end

      # Container CIDR
      #
      # Returns the CIDR of the container
      #
      # @return [Integer] The containers CIDR address.
      def cidr
        TestLab::Utility.cidr(self.primary_interface.address).to_i
      end

      # Container BIND PTR Record
      #
      # Returns a BIND reverse-DNS PTR record.
      #
      # @return [String] The containers ARPA PTR record.
      def ptr
        TestLab::Utility.ptr(self.primary_interface.address)
      end

      # Container FQDN
      #
      # Returns the FQDN for the container.
      #
      # @return [String] The containers FQDN.
      def fqdn
        self.domain ||= self.node.labfile.config[:domain]

        [self.id, self.domain].join('.')
      end

      # Container Status
      #
      # Returns a hash of status information for the container.
      #
      # @return [Hash] A hash of status information for the container.
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
      #
      # @return [Symbol] A symbol indicating the state of the container.
      def state
        self.lxc.state
      end

    end

  end
end
