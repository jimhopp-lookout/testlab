class TestLab
  class Network

    module Lifecycle

      # Network Setup
      def setup
        @ui.logger.debug { "Network Setup: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          self.route and manage_route(:add)

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NETWORK PROVISIONER SETUP: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_teardown) and p.on_node_teardown(self)
          end

        end

        true
      end

      # Network Teardown
      def teardown
        @ui.logger.debug { "Network Teardown: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NETWORK PROVISIONER TEARDOWN: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_node_teardown) and p.on_node_teardown(self)
          end

          self.route and manage_route(:del)
        end

        true
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
