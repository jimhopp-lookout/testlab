class TestLab
  class Container

    module Network

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
