class TestLab
  class Network

    module Lifecycle

      # Network Setup
      def setup
        @ui.logger.debug { "Network Setup: #{self.id} " }

        self.create
        self.up
        self.route and route(:add)
      end

      # Network Teardown
      def teardown
        @ui.logger.debug { "Network Teardown: #{self.id} " }

        self.route and route(:del)
        self.down
        self.destroy
      end

      def route(action)
        self.networks.each do |network|
          command = ZTK::Command.new(:ui => @ui, :silence => true, :ignore_exit_status => true)

          case RUBY_PLATFORM
          when /darwin/ then
            command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.address)} #{network.node.ip} #{TestLab::Utility.netmask(network.address)}))
          when /linux/ then
            command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(network.address)} netmask #{TestLab::Utility.netmask(network.address)} gw #{network.node.ip}))
          end
        end
      end

    end

  end
end
