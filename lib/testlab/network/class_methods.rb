class TestLab
  class Network

    module ClassMethods

      def ips
        self.all.map(&:ip).collect{ |ip| TestLab::Utility.ip(ip) }.compact
      end

    end

  end
end
