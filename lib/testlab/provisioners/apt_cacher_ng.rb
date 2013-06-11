class TestLab

  class Provisioner

    # AptCacherNG Provisioner Error Class
    class AptCacherNGError < ProvisionerError; end

    # AptCacherNG Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class AptCacherNG

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # AptCacherNG Provisioner Node Setup
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def node(node)
        @ui.logger.debug { "AptCacherNG Provisioner: Node #{node.id}" }

        node.ssh.exec(%(sudo apt-get -y install apt-cacher-ng))
        node.ssh.exec(%(sudo service apt-cacher-ng restart || sudo service apt-cacher-ng start))
        node.ssh.exec(%(echo 'Acquire::HTTP { Proxy "http://127.0.0.1:3142"; };' | sudo tee /etc/apt/apt.conf.d/00proxy))
        node.ssh.exec(%(sudo grep "^MIRROR" /etc/default/lxc || echo 'MIRROR="http://127.0.0.1:3142/archive.ubuntu.com/ubuntu"' | sudo tee -a /etc/default/lxc))
        node.ssh.exec(%(sudo service lxc restart || sudo service lxc start))

        true
      end

      # AptCacherNG Provisioner Container Setup
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def setup(container)
        @ui.logger.debug { "AptCacherNG Provisioner: Container #{container.id}" }

        # Ensure the container APT calls use apt-cacher-ng on the node
        gateway_ip            = container.primary_interface.network.ip
        apt_conf_d_proxy_file = File.join(container.lxc.fs_root, "etc", "apt", "apt.conf.d", "00proxy")

        container.node.ssh.exec(%(sudo mkdir -pv #{File.dirname(apt_conf_d_proxy_file)}))

        container.node.ssh.exec(%(echo 'Acquire::HTTP { Proxy "http://#{gateway_ip}:3142"; };' | sudo tee #{apt_conf_d_proxy_file}))
        container.config[:apt_cacher_exclude_hosts].each do |host|
          container.node.ssh.exec(%(echo 'Acquire::HTTP::Proxy::#{host} "DIRECT";' | sudo tee -a #{apt_conf_d_proxy_file}))
        end

        # Fix the APT sources since LXC mudges them when using apt-cacher-ng
        apt_conf_sources_file = File.join(container.lxc.fs_root, "etc", "apt", "sources.list")
        container.node.ssh.exec(%(sudo sed -i 's/127.0.0.1:3142\\///g' #{apt_conf_sources_file}))
      end

      # AptCacherNG Provisioner Container Teardown
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
