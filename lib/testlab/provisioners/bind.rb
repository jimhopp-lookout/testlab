class TestLab

  class Provisioner

    # Bind Provisioner Error Class
    class BindError < ProvisionerError; end

    # Bind Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Bind

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        @config[:bind] ||= Hash.new
        @config[:bind][:domain] ||= "default.zone"

        @ui.logger.debug { "config(#{@config.inspect})" }
      end

      # Bind: Node Provision
      #
      # @param [TestLab::Node] node The node that is being provisioned.
      # @return [Boolean] True if successful.
      def on_node_provision(node)
        @ui.logger.debug { "BIND Provisioner: Node #{node.id}" }

        bind_provision(node)

        true
      end

      # Bind: Node Deprovision
      #
      # @param [TestLab::Node] node The node which we want to deprovision.
      # @return [Boolean] True if successful.
      def on_node_deprovision(node)
        node.ssh.exec(%(DEBIAN_FRONTEND="noninteractive" sudo apt-get -y purge bind9))

        true
      end

      # Bind: Network Up
      #
      # @param [TestLab::Network] network The network that is being onlined.
      # @return [Boolean] True if successful.
      def on_network_up(network)
        @ui.logger.debug { "BIND Provisioner: Network #{network.id}" }

        bind_reload(network.node)

        true
      end

      # Builds the main bind configuration sections
      def build_bind_main_partial(file)
        bind_conf_template = File.join(TestLab::Provisioner.template_dir, "bind", "bind.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND Configuration", :char => '//'))
        file.puts(ZTK::Template.render(bind_conf_template, {}))
      end

      def build_bind_records
        forward_records = Hash.new
        reverse_records = Hash.new

        TestLab::Container.all.each do |container|
          container.domain ||= @config[:bind][:domain]

          container.interfaces.each do |interface|
            forward_records[container.domain] ||= Array.new
            forward_records[container.domain] << %(#{container.id} IN A #{interface.ip})

            reverse_records[interface.network_id] ||= Array.new
            reverse_records[interface.network_id] << %(#{interface.ptr} IN PTR #{container.fqdn}.)
          end

        end
        { :forward => forward_records, :reverse => reverse_records }
      end

      # Builds the bind configuration sections for our zones
      def build_bind_zone_partial(ssh, file)
        bind_zone_template = File.join(TestLab::Provisioner.template_dir, "bind", 'bind-zone.erb')

        bind_records = build_bind_records
        forward_records = bind_records[:forward]
        reverse_records = bind_records[:reverse]

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(ssh, network.arpa, reverse_records[network.id])
        end

        TestLab::Container.domains.each do |domain|
          context = {
            :zone => domain
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(ssh, domain, forward_records[domain])
        end
      end

      def build_bind_db(ssh, zone, records)
        bind_db_template = File.join(TestLab::Provisioner.template_dir, "bind", 'bind-db.erb')

        ssh.file(:target => %(/etc/bind/db.#{zone}), :chown => "bind:bind") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end
      end

      # Builds the BIND configuration
      def build_bind_conf(ssh)
        ssh.file(:target => %(/etc/bind/named.conf), :chown => "bind:bind") do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(ssh, file)
        end
      end

      def bind_install(ssh)
        ssh.exec(%(DEBIAN_FRONTEND="noninteractive" sudo apt-get -y install bind9))
        ssh.exec(%(sudo rm -fv /etc/bind/{*.arpa,*.zone,*.conf*}))
      end

      def bind_reload(node)
        node.ssh.exec(%(sudo chown -Rv bind:bind /etc/bind))
        node.ssh.exec(%(sudo rndc reload))
      end

      def bind_provision(node)
        bind_install(node.ssh)
        build_bind_conf(node.ssh)
        bind_reload(node)
      end

    end

  end
end
