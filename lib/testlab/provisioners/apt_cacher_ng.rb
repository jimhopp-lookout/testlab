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
        @config[:apt][:cacher_ng][:exclude_hosts] ||= Array.new

        @apt_conf_d_proxy_file_template = File.join(TestLab::Provisioner.template_dir, "apt_cacher_ng", "00proxy.erb")
        @apt_cacher_ng_security_conf_template = File.join(TestLab::Provisioner.template_dir, "apt_cacher_ng", "security.conf.erb")

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # APT-CacherNG Provisioner Node Setup
      #
      # @param [TestLab::Node] node The node which we want to provision.
      # @return [Boolean] True if successful.
      def on_node_setup(node)
        @ui.logger.debug { "APT-CacherNG Provisioner: Node #{node.id}" }

        bootstrap_template = File.join(TestLab::Provisioner.template_dir, "apt_cacher_ng", "bootstrap.erb")
        node.ssh.bootstrap(ZTK::Template.render(bootstrap_template, @config))

        context = {
          :apt => {
            :cacher_ng => {
              :proxy_url => "http://127.0.0.1:3142",
              :exclude_hosts => Array.new
            }
          }
        }

        apt_conf_d_proxy_file = %(/etc/apt/apt.conf.d/00proxy)
        node.ssh.file(:target => apt_conf_d_proxy_file, :chown => "root:root", :chmod => "0644") do |file|
          file.puts(ZTK::Template.render(@apt_conf_d_proxy_file_template, context))
        end

        apt_cacher_ng_security_conf_file = %(/etc/apt-cacher-ng/security.conf)
        node.ssh.file(:target => apt_cacher_ng_security_conf_file, :chown => "root:root", :chmod => "0644") do |file|
          file.puts(ZTK::Template.render(@apt_cacher_ng_security_conf_template, context))
        end

        node.ssh.exec(%(sudo service apt-cacher-ng restart))

        true
      end

      # APT-CacherNG Provisioner Container Setup
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def on_container_setup(container)
        @ui.logger.debug { "APT-CacherNG Provisioner: Container #{container.id}" }

        # Ensure the container APT calls use apt-cacher-ng on the node
        gateway_ip                     = container.primary_interface.network.ip
        apt_conf_d_proxy_file          = %(/etc/apt/apt.conf.d/00proxy)

        @config[:apt][:cacher_ng] = { :proxy_url => "http://#{gateway_ip}:3142" }.merge(@config[:apt][:cacher_ng])

        container.ssh.file(:target => apt_conf_d_proxy_file, :chown => "root:root", :chmod => "0644") do |file|
          file.puts(ZTK::Template.render(@apt_conf_d_proxy_file_template, @config))
        end

        # Fix the APT sources since LXC mudges them when using apt-cacher-ng
        apt_conf_sources_file = %(/etc/apt/sources.list)
        container.ssh.exec(%(sudo sed -i 's/127.0.0.1:3142\\///g' #{apt_conf_sources_file}))
      end

    end

  end
end
