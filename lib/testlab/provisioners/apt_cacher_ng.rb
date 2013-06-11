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

        script = <<-EOF
apt-get -y install apt-cacher-ng
service apt-cacher-ng restart || service apt-cacher-ng start
echo 'Acquire::HTTP { Proxy "http://127.0.0.1:3142"; };' | tee /etc/apt/apt.conf.d/00proxy
grep "^MIRROR" /etc/default/lxc || echo 'MIRROR="http://127.0.0.1:3142/archive.ubuntu.com/ubuntu"' | tee -a /etc/default/lxc && service lxc restart || service lxc start
        EOF

        node.ssh.bootstrap(script)

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

        script = <<-EOF
mkdir -pv #{File.dirname(apt_conf_d_proxy_file)}
echo 'Acquire::HTTP { Proxy "http://#{gateway_ip}:3142"; };' | tee #{apt_conf_d_proxy_file}
        EOF

        container.config[:apt_cacher_exclude_hosts].each do |host|
          script << %(echo 'Acquire::HTTP::Proxy::#{host} "DIRECT";' | tee -a #{apt_conf_d_proxy_file}\n)
        end

        # Fix the APT sources since LXC mudges them when using apt-cacher-ng
        apt_conf_sources_file = File.join(container.lxc.fs_root, "etc", "apt", "sources.list")
        script << %(sed -i 's/127.0.0.1:3142\\///g' #{apt_conf_sources_file}\n)

        container.node.ssh.bootstrap(script)
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
