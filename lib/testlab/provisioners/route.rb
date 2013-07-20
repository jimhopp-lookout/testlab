class TestLab

  class Provisioner

    # Route Provisioner Error Class
    class RouteError < ProvisionerError; end

    # Route Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Route
      include TestLab::Utility::Misc

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:route] ||= Hash.new

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Route: Network Provision
      def on_network_provision(network)
        manage_route(:add, network)

        true
      end
      alias :on_network_up :on_network_provision

      # Route: Network Deprovision
      def on_network_deprovision(network)
        manage_route(:del, network)

        true
      end
      alias :on_network_down :on_network_deprovision

      def manage_route(action, network)
        command = ZTK::Command.new(:ui => @ui, :silence => true, :ignore_exit_status => true)

        case RUBY_PLATFORM
        when /darwin/ then
          action = ((action == :del) ? :delete : :add)
          command.exec(%(#{sudo} route #{action} -net #{TestLab::Utility.network(network.address)} #{network.node.ip} #{TestLab::Utility.netmask(network.address)}))
        when /linux/ then
          command.exec(%(#{sudo} route #{action} -net #{TestLab::Utility.network(network.address)} netmask #{TestLab::Utility.netmask(network.address)} gw #{network.node.ip}))
        end
      end

    end

  end
end
