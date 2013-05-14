class TestLab
  class Network

    module Lifecycle

      # Network Setup
      def setup
        @ui.logger.debug { "Network Setup: #{self.id} " }

        self.create
        self.up
        self.route and manage_route(:add)
      end

      # Network Teardown
      def teardown
        @ui.logger.debug { "Network Teardown: #{self.id} " }

        self.route and manage_route(:del)
        self.down
        self.destroy
      end

      def manage_route(action)
        command = ZTK::Command.new(:ui => @ui, :silence => true, :ignore_exit_status => true)

        case RUBY_PLATFORM
        when /darwin/ then
          action = ((action == :del) ? :delete : :add)
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(self.address)} #{self.node.ip} #{TestLab::Utility.netmask(self.address)}))
        when /linux/ then
          command.exec(%(sudo route #{action} -net #{TestLab::Utility.network(self.address)} netmask #{TestLab::Utility.netmask(self.address)} gw #{self.node.ip}))
        end
      end

    end

  end
end
