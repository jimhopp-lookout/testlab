class TestLab
  class Container

    module Interface

      def ip
        self.primary_interface.last[:ip].split('/').first
      end

      # Returns the CIDR of the container
      def cidr
        self.primary_interface.last[:ip].split('/').last.to_i
      end

      def ptr
        octets = self.ip.split('.')

        result = case self.cidr
        when 0..7 then
          octets[-4,4]
        when 8..15 then
          octets[-3,3]
        when 16..23 then
          octets[-2,2]
        when 24..31 then
          octets[-1,1]
        end

        result.reverse.join('.')
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
