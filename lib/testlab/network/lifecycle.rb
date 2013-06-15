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

        end

        true
      end

    end

  end
end
