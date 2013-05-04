class TestLab
  class Network

    module ClassMethods

      def ips
        self.all.map(&:address).collect{ |address| TestLab::Utility.ip(address) }.compact
      end

    end

  end
end
