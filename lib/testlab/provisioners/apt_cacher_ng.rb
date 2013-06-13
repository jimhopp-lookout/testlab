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

        @config[:apt] ||= Hash.new
        @config[:apt][:cacher_ng] ||= Hash.new
        @config[:apt][:cacher_ng][:proxy_url]     ||= "http://127.0.0.1:3142"
        @config[:apt][:cacher_ng][:exclude_hosts] ||= Array.new

        @apt_conf_d_proxy_file_template = File.join(TestLab::Provisioner.template_dir, "apt_cacher_ng", "00proxy.erb")

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # AptCacherNG Provisioner Node Setup
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def node(node)
        @ui.logger.debug { "AptCacherNG Provisioner: Node #{node.id}" }

        node.ssh.bootstrap(<<-EOF
apt-get -y install apt-cacher-ng
service apt-cacher-ng restart || service apt-cacher-ng start
grep "^MIRROR" /etc/default/lxc || echo 'MIRROR="http://127.0.0.1:3142/archive.ubuntu.com/ubuntu"' | tee -a /etc/default/lxc && service lxc restart || service lxc start
        EOF
        )

        apt_conf_d_proxy_file = File.join("/etc", "apt", "apt.conf.d", "00proxy")

        context = {
          :apt => {
            :cacher_ng => {
              :proxy_url => "http://127.0.0.1:3142",
              :exclude_hosts => Array.new
            }
          }
        }

        node.ssh.file(:target => apt_conf_d_proxy_file, :chown => "root:root", :chmod => "0644") do |file|
          file.puts(ZTK::Template.render(@apt_conf_d_proxy_file_template, context))
        end

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
        gateway_ip                     = container.primary_interface.network.ip
        apt_conf_d_proxy_file          = File.join(container.lxc.fs_root, "etc", "apt", "apt.conf.d", "00proxy")

        @config[:apt][:cacher_ng].merge!(:proxy_url => "http://#{gateway_ip}:3142").merge!(@config[:apt][:cacher_ng])

        container.node.ssh.file(:target => apt_conf_d_proxy_file, :chown => "root:root", :chmod => "0644") do |file|
          file.puts(ZTK::Template.render(@apt_conf_d_proxy_file_template, @config))
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
