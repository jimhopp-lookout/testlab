class TestLab
  class Container

    module Generators

      # Generate IP address
      #
      # Generates an RFC compliant private IP address.
      #
      # @return [String] A random, private IP address in the 192.168.0.1/24
      #   range.
      def generate_ip
        octets = [ 192..192,
                   168..168,
                   0..254,
                   1..254 ]
        ip = Array.new
        for x in 1..4 do
          ip << octets[x-1].to_a[rand(octets[x-1].count)].to_s
        end
        ip.join(".")
      end

      # Generate MAC address
      #
      # Generates an RFC compliant private MAC address.
      #
      # @return [String] A random, private MAC address.
      def generate_mac
        digits = [ %w(0),
                   %w(0),
                   %w(0),
                   %w(0),
                   %w(5),
                   %w(e),
                   %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                   %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                   %w(5 6 7 8 9 a b c d e f),
                   %w(3 4 5 6 7 8 9 a b c d e f),
                   %w(0 1 2 3 4 5 6 7 8 9 a b c d e f),
                   %w(0 1 2 3 4 5 6 7 8 9 a b c d e f) ]
        mac = ""
        for x in 1..12 do
          mac += digits[x-1][rand(digits[x-1].count)]
          mac += ":" if (x.modulo(2) == 0) && (x != 12)
        end
        mac
      end

    end

  end
end
