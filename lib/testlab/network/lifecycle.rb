class TestLab
  class Network

    module Lifecycle

      # Network Setup
      def setup
        @ui.logger.debug { "Network Setup: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> NETWORK PROVISIONER SETUP: #{provisioner} <<<<<" }
            p = provisioner.new(self.config, @ui)
            p.respond_to?(:on_network_setup) and p.on_network_setup(self)
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
            p.respond_to?(:on_network_teardown) and p.on_network_teardown(self)
          end

        end

        true
      end

      # Build the network
      def build
        self.create
        self.up
        self.setup

        true
      end

    end

  end
end
