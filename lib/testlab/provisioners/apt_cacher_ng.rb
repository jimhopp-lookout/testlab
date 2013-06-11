class TestLab

  class Provisioner

    # AptcAcherNG Provisioner Error Class
    class AptCacherNGError < ProvisionerError; end

    # AptcAcherNG Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class AptCacherNG

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # AptcAcherNG Provisioner Container Setup
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def setup(container)
        # Ensure the container APT calls use apt-cacher-ng on the node
        gateway_ip = container.primary_interface.network.ip
        apt_conf_d_proxy_file = File.join(container.lxc.fs_root, "etc", "apt", "apt.conf.d", "00proxy")
        container.node.ssh.exec(%(sudo mkdir -pv #{File.dirname(apt_conf_d_proxy_file)}))
        container.node.ssh.exec(%(echo 'Acquire::HTTP { Proxy "http://#{gateway_ip}:3142"; };' | sudo tee #{apt_conf_d_proxy_file}))
        container.config.has_key?(:apt_cacher_exclude_hosts) and container.config[:apt_cacher_exclude_hosts].each do |host|
          container.node.ssh.exec(%(echo 'Acquire::HTTP::Proxy::#{host} "DIRECT";' | sudo tee -a #{apt_conf_d_proxy_file}))
        end

        # Fix the APT sources since LXC mudges them when using apt-cacher-ng
        apt_conf_sources_file = File.join(container.lxc.fs_root, "etc", "apt", "sources.list")
        container.node.ssh.exec(%(sudo sed -i 's/127.0.0.1:3142\\///g' #{apt_conf_sources_file}))
      end

      # AptcAcherNG Provisioner Container Teardown
      #
      # This is a NO-OP currently.
      #
      # @return [Boolean] True if successful.
      def teardown(container)
        # NOOP

        true
      end

    end

  end
end
