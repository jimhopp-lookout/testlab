class TestLab
  class Container

    module Status

      def fqdn
        self.domain ||= self.node.labfile.config[:domain]

        [self.id, self.domain].join('.')
      end

      def status
        interfaces = self.interfaces.collect{ |network, network_config| "#{network}:#{network_config[:name]}:#{network_config[:ip]}" }.join(', ')
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

      # State of the container
      def state
        self.lxc.state
      end

    end

  end
end
