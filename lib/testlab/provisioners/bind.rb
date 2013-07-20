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
        @config[:bind][:domain]     ||= "tld.invalid"
        @config[:bind][:forwarders] ||= %w(8.8.8.8 8.8.4.4)


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
        @ui.logger.debug { "BIND Deprovisioner: Node #{node.id}" }

        node.exec(%(sudo DEBIAN_FRONTEND="noninteractive" apt-get -y purge bind9))

        true
      end

      # Bind: Container Up
      #
      # @param [TestLab::Container] container The container which just came online.
      # @return [Boolean] True if successful.
      def on_container_up(container)
        @ui.logger.debug { "BIND Provisioner: Container #{container.id}" }

        bind_reload(container.node)

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
        file.puts(ZTK::Template.render(bind_conf_template, @config))
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
      def build_bind_zone_partial(node, file)
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

          build_bind_db(node, network.arpa, reverse_records[network.id])
        end

        TestLab::Container.domains.each do |domain|
          context = {
            :zone => domain
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(node, domain, forward_records[domain])
        end
      end

      def build_bind_db(node, zone, records)
        bind_db_template = File.join(TestLab::Provisioner.template_dir, "bind", 'bind-db.erb')

        node.file(:target => %(/etc/bind/db.#{zone}), :chown => "bind:bind") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end
      end

      # Builds the BIND configuration
      def build_bind_conf(node)
        node.file(:target => %(/etc/bind/named.conf), :chown => "bind:bind") do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(node, file)
        end
      end

      def bind_install(node)
        node.exec(%(sudo DEBIAN_FRONTEND="noninteractive" apt-get -y install bind9))
        node.exec(%(sudo rm -fv /etc/bind/{*.arpa,*.zone,*.conf*}))
      end

      def bind_reload(node)
        node.exec(%(sudo chown -Rv bind:bind /etc/bind))
        node.exec(%(sudo rndc reload))
      end

      def bind_provision(node)
        bind_install(node)
        build_bind_conf(node)
        bind_reload(node)
      end

    end

  end
end
