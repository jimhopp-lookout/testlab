class TestLab
  class Node

    module Bind
      require 'tempfile'

      # Builds the main bind configuration sections
      def build_bind_main_partial(file)
        bind_conf_template = File.join(self.class.template_dir, "bind.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND Configuration", :char => '//'))
        file.puts(ZTK::Template.render(bind_conf_template, {}))
      end

      def build_bind_records
        forward_records = Hash.new
        reverse_records = Hash.new

        TestLab::Container.all.each do |container|
          interface = container.primary_interface
          domain       = (container.domain || container.node.labfile.config[:domain])

          forward_records[domain] ||= Array.new
          forward_records[domain] << %(#{container.id} IN A #{container.ip})

          reverse_records[interface.first] ||= Array.new
          reverse_records[interface.first] << %(#{container.ptr} IN PTR #{container.id}.#{domain}.)
        end
        { :forward => forward_records, :reverse => reverse_records }
      end

      # Builds the bind configuration sections for our zones
      def build_bind_zone_partial(file)
        bind_zone_template = File.join(self.class.template_dir, 'bind-zone.erb')

        bind_records = build_bind_records
        forward_records = bind_records[:forward]
        reverse_records = bind_records[:reverse]

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(network.arpa, reverse_records[network.id])
        end

        domains = ([self.labfile.config[:domain]] + TestLab::Container.domains).flatten
        domains.each do |domain|
          context = {
            :zone => domain
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(domain, forward_records[domain])
        end
      end

      def build_bind_db(zone, records)
        bind_db_template = File.join(self.class.template_dir, 'bind-db.erb')

        self.ssh.file(:target => "/etc/bind/db.#{zone}", :chown => "bind:bind") do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end

        # self.ssh.exec(%(sudo rm -fv /etc/bind/db.#{zone}.jnl))
      end

      # Builds the BIND configuration
      def build_bind_conf
        self.ssh.file(:target => File.join("/etc/bind/named.conf"), :chown => "bind:bind") do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(file)
        end
      end

      def bind_setup
        self.ssh.exec(%(sudo /bin/bash -c 'apt-get -y install bind9'))

        build_bind_conf

        self.ssh.exec(%(sudo /bin/bash -c 'service bind9 stop ; service bind9 start'))
      end

    end

  end
end
