class TestLab
  class Network

    module Bind

      # BIND PTR Record
      def ptr
        TestLab::Utility.ptr(self.address)
      end

      # Returns the ARPA network
      def arpa
        TestLab::Utility.arpa(self.address)
      end

    end

  end
end
