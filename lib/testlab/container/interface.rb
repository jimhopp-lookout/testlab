class TestLab
  class Container

    module Interface

      # Container primary interface
      #
      # Returns the primary interface for the container.  If the container has
      # multiple interfaces, this is based on which ever interface is marked
      # with the primary flag.  If the container only has one interface, then
      # it is returned.
      #
      # @return [TestLab::Interface] The primary interface for the container.
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
