class TestLab
  class Container

    module Interface

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
