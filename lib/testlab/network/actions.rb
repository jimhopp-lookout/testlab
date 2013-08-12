class TestLab
  class Network

    module Actions

      # Create the network
      def create
        @ui.logger.debug { "Network Create: #{self.id} " }

        (self.node.state == :running) or return false
        (self.state == :not_created) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          self.node.bootstrap(<<-EOF, :ignore_exit_status => true)
set -x
grep '#{def_tag}' /etc/network/interfaces && exit 0
cat <<EOI | tee -a /etc/network/interfaces
#{def_tag}
auto #{self.bridge}
iface #{self.bridge} inet static
      bridge_ports none
      bridge_stp off
      bridge_fd 0
      address #{self.ip}
      broadcast #{self.broadcast}
      netmask #{self.netmask}
#{end_tag}
EOI
brctl addbr #{self.bridge}
brctl stp #{self.bridge} off
brctl setfd #{self.bridge} 0
          EOF

          do_provisioner_callbacks(self, :create, @ui)
        end

        true
      end

      # Destroy the network
      def destroy
        @ui.logger.debug { "Network Destroy: #{self.id} " }

        (self.node.state == :running) or return false
        (self.state != :not_created) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          self.node.bootstrap(<<-EOF, :ignore_exit_status => true)
set -x
sed -i '/#{def_tag}/,/#{end_tag}/d' /etc/network/interfaces
brctl delbr #{self.bridge}
          EOF

          do_provisioner_callbacks(self, :destroy, @ui)
        end

        true
      end

      # Start the network
      def up
        @ui.logger.debug { "Network Up: #{self.id} " }

        (self.node.state == :running) or return false
        # (self.state != :running) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          self.node.bootstrap(<<-EOF, :ignore_exit_status => true)
set -x
ifconfig #{self.bridge} #{self.ip} netmask #{self.netmask} broadcast #{self.broadcast} up
          EOF

          do_provisioner_callbacks(self, :up, @ui)
        end

        true
      end

      # Stop the network
      def down
        @ui.logger.debug { "Network Down: #{self.id} " }

        (self.node.state == :running) or return false
        # (self.state == :running) or return false

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          self.node.bootstrap(<<-EOF, :ignore_exit_status => true)
set -x
ifconfig #{self.bridge} down
          EOF

          do_provisioner_callbacks(self, :down, @ui)
        end

        true
      end

    end

  end
end
