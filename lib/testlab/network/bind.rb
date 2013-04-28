class TestLab
  class Network

    module Bind

      # BIND PTR Record
      def ptr
        TestLab::Utility.ptr(self.ip)
      end

      # Returns the ARPA network
      def arpa
        TestLab::Utility.arpa(self.ip)
      end

    end

  end
end
