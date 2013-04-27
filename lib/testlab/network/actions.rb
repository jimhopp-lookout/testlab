class TestLab
  class Network

    module Actions

      # Create the network
      def create
        @ui.logger.debug { "Network Create: #{self.id} " }

        self.node.ssh.exec(%(sudo brctl addbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
      end

      # Destroy the network
      def destroy
        @ui.logger.debug { "Network Destroy: #{self.id} " }

        self.node.ssh.exec(%(sudo brctl delbr #{self.bridge}), :silence => true, :ignore_exit_status => true)
      end

      # Start the network
      def up
        @ui.logger.debug { "Network Up: #{self.id} " }

        self.node.ssh.exec(%(sudo ifconfig #{self.bridge} #{self.ip} up), :silence => true, :ignore_exit_status => true)
      end

      # Stop the network
      def down
        @ui.logger.debug { "Network Down: #{self.id} " }

        self.node.ssh.exec(%(sudo ifconfig #{self.bridge} down), :silence => true, :ignore_exit_status => true)
      end

    end

  end
end
