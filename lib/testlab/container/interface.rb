class TestLab
  class Container

    module Interface

      # Returns the IP of the container
      def ip
        TestLab::Utility.ip(self.primary_interface.address)
      end

      # Returns the CIDR of the container
      def cidr
        TestLab::Utility.cidr(self.primary_interface.address).to_i
      end

      # Returns a BIND PTR record
      def ptr
        TestLab::Utility.ptr(self.primary_interface.address)
      end

      # Returns the primary interface for the container
      def primary_interface
        if self.interfaces.any?{ |i| i.primary == true }
          self.interfaces.find{ |i| i.primary == true }
        else
          self.interfaces.first
        end
      end

    end

  end
end
