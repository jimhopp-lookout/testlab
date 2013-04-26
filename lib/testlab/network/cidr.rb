class TestLab
  class Network

    module CIDR

      CIDR_MATRIX = {
        32 => { :netmask => '255.255.255.255', :broadcast => '%s.%s.%s.%s',     :network => '%s.%s.%s.%s' },
        31 => { :netmask => '255.255.255.254', :broadcast => '%s.%s.%s.1',      :network => '%s.%s.%s.254' },
        30 => { :netmask => '255.255.255.252', :broadcast => '%s.%s.%s.3',      :network => '%s.%s.%s.252' },
        29 => { :netmask => '255.255.255.248', :broadcast => '%s.%s.%s.7',      :network => '%s.%s.%s.248' },
        28 => { :netmask => '255.255.255.240', :broadcast => '%s.%s.%s.15',     :network => '%s.%s.%s.240' },
        27 => { :netmask => '255.255.255.224', :broadcast => '%s.%s.%s.31',     :network => '%s.%s.%s.224' },
        26 => { :netmask => '255.255.255.192', :broadcast => '%s.%s.%s.63',     :network => '%s.%s.%s.192' },
        25 => { :netmask => '255.255.255.128', :broadcast => '%s.%s.%s.127',    :network => '%s.%s.%s.128' },
        24 => { :netmask => '255.255.255.0',   :broadcast => '%s.%s.%s.255',    :network => '%s.%s.%s.0' },
        23 => { :netmask => '255.255.254.0',   :broadcast => '%s.%s.1.255',     :network => '%s.%s.254.0' },
        22 => { :netmask => '255.255.252.0',   :broadcast => '%s.%s.3.255',     :network => '%s.%s.252.0' },
        21 => { :netmask => '255.255.248.0',   :broadcast => '%s.%s.7.255',     :network => '%s.%s.248.0' },
        20 => { :netmask => '255.255.240.0',   :broadcast => '%s.%s.15.255',    :network => '%s.%s.240.0' },
        19 => { :netmask => '255.255.224.0',   :broadcast => '%s.%s.31.255',    :network => '%s.%s.224.0' },
        18 => { :netmask => '255.255.192.0',   :broadcast => '%s.%s.63.255',    :network => '%s.%s.192.0' },
        17 => { :netmask => '255.255.128.0',   :broadcast => '%s.%s.127.255',   :network => '%s.%s.128.0' },
        16 => { :netmask => '255.255.0.0',     :broadcast => '%s.%s.255.255',   :network => '%s.%s.0.0' },
        15 => { :netmask => '255.254.0.0',     :broadcast => '%s.1.255.255',    :network => '%s.254.0.0' },
        14 => { :netmask => '255.252.0.0',     :broadcast => '%s.3.255.255',    :network => '%s.252.0.0' },
        13 => { :netmask => '255.248.0.0',     :broadcast => '%s.7.255.255',    :network => '%s.248.0.0' },
        12 => { :netmask => '255.240.0.0',     :broadcast => '%s.15.255.255',   :network => '%s.240.0.0' },
        11 => { :netmask => '255.224.0.0',     :broadcast => '%s.31.255.255',   :network => '%s.224.0.0' },
        10 => { :netmask => '255.192.0.0',     :broadcast => '%s.63.255.255',   :network => '%s.192.0.0' },
         9 => { :netmask => '255.128.0.0',     :broadcast => '%s.127.255.255',  :network => '%s.128.0.0' },
         8 => { :netmask => '255.0.0.0',       :broadcast => '%s.255.255.255',  :network => '%s.0.0.0' },
         7 => { :netmask => '254.0.0.0',       :broadcast => '1.255.255.255',   :network => '254.0.0.0' },
         6 => { :netmask => '252.0.0.0',       :broadcast => '3.255.255.255',   :network => '252.0.0.0' },
         5 => { :netmask => '248.0.0.0',       :broadcast => '7.255.255.255',   :network => '248.0.0.0' },
         4 => { :netmask => '240.0.0.0',       :broadcast => '15.255.255.255',  :network => '240.0.0.0' },
         3 => { :netmask => '224.0.0.0',       :broadcast => '31.255.255.255',  :network => '224.0.0.0' },
         2 => { :netmask => '192.0.0.0',       :broadcast => '63.255.255.255',  :network => '192.0.0.0' },
         1 => { :netmask => '128.0.0.0',       :broadcast => '127.255.255.255', :network => '128.0.0.0' },
         0 => { :netmask => '0.0.0.0',         :broadcast => '255.255.255.255', :network => '0.0.0.0' }
      }

      # Returns the CIDR of the network
      def cidr
        self.ip.split('/').last
      end

      # Returns the IP with the CIDR notation stripped away
      def clean_ip
        ip = self.ip.split('/').first
      end

      # Returns the entry from the CIDR_MATRIX constant based on our CIDR
      def cidr_matrix
        CIDR_MATRIX[self.cidr.to_i]
      end

      # Returns the network mask
      def netmask
        cidr_matrix[:netmask]
      end

      # Returns the network address
      def network
        cidr_matrix[:network] % clean_ip.split('.')
      end

      # Returns the broadcast address
      def broadcast
        cidr_matrix[:broadcast] % clean_ip.split('.')
      end

    end

  end
end
