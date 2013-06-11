class TestLab
  class Container

    module Lifecycle

      # Setup the container
      #
      # Attempts to setup the container.  We first create the container, then
      # attempt to bring it online.  Afterwards the containers provisioner is
      # called.
      #
      # @return [Boolean] True if successful.
      def setup
        @ui.logger.debug { "Container Setup: #{self.id} " }

        self.create
        self.up

        if (!@provisioner.nil? && @provisioner.respond_to?(:setup))
          please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

            # Ensure the container APT calls use apt-cacher-ng on the node
            gateway_ip = self.primary_interface.network.ip
            apt_conf_d_proxy_file = File.join(self.lxc.fs_root, "etc", "apt", "apt.conf.d", "00proxy")
            self.node.ssh.exec(%(sudo mkdir -pv #{File.dirname(apt_conf_d_proxy_file)}))
            self.node.ssh.exec(%(echo 'Acquire::HTTP { Proxy "http://#{gateway_ip}:3142"; };' | sudo tee #{apt_conf_d_proxy_file}))
            self.config.has_key?(:apt_cacher_exclude_hosts) and self.config[:apt_cacher_exclude_hosts].each do |host|
              self.node.ssh.exec(%(echo 'Acquire::HTTP::Proxy::#{host} "DIRECT";' | sudo tee -a #{apt_conf_d_proxy_file}))
            end

            # Fix the APT sources since LXC mudges them when using apt-cacher-ng
            apt_conf_sources_file = File.join(self.lxc.fs_root, "etc", "apt", "sources.list")
            self.node.ssh.exec(%(sudo sed -i 's/127.0.0.1:3142\\///g' #{apt_conf_sources_file}))

            self.users.each do |user|
              user.setup
            end

            @provisioner.setup(self)

          end
        end

        true
      end

      # Teardown the container
      #
      # Attempts to teardown the container.  We first call the provisioner
      # teardown method defined for the container, if any.  Next we attempt to
      # offline the container.  Afterwards the container is destroy.
      #
      # @return [Boolean] True if successful.
      def teardown
        @ui.logger.debug { "Container Teardown: #{self.id} " }

        if (!@provisioner.nil? && @provisioner.respond_to?(:teardown))
          please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do
            @provisioner.teardown(self)
          end
        end

        self.down
        self.destroy

        true
      end

    end

  end
end
