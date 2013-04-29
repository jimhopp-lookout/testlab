class TestLab
  class Container

    module Interface

      # Returns the IP of the container
      def ip
        TestLab::Utility.ip(self.primary_interface.last[:ip])
      end

      # Returns the CIDR of the container
      def cidr
        TestLab::Utility.cidr(self.primary_interface.last[:ip]).to_i
      end

      # Returns a BIND PTR record
      def ptr
        TestLab::Utility.ptr(self.primary_interface.last[:ip])
      end

      def primary_interface
        if self.interfaces.any?{ |i,c| c[:primary] == true }
          self.interfaces.find{ |i,c| c[:primary] == true }
        else
          self.interfaces.first
        end
      end

    end

  end
end
