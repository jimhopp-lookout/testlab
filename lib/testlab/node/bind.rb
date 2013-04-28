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
          tld       = (container.tld || container.node.labfile.config[:tld])

          forward_records[tld] ||= Array.new
          forward_records[tld] << %(#{container.id} IN A #{container.ip})

          reverse_records[interface.first] ||= Array.new
          reverse_records[interface.first] << %(#{container.ptr} IN PTR #{container.id}.#{tld}.)
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

        tlds = ([self.labfile.config[:tld]] + TestLab::Container.tlds).flatten
        tlds.each do |tld|
          context = {
            :zone => tld
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(tld, forward_records[tld])
        end
      end

      def build_bind_db(zone, records)
        bind_db_template = File.join(self.class.template_dir, 'bind-db.erb')

        tempfile = Tempfile.new("bind-db")
        File.open(tempfile, 'w') do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB: #{zone}", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, { :zone => zone, :records => records }))
        end
        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} /etc/bind/db.#{zone}))
        self.ssh.exec(%(sudo rm -fv /etc/bind/db.#{zone}.jnl))
      end

      # Builds the BIND configuration
      def build_bind_conf
        bind_conf = File.join("/etc/bind/named.conf")
        tempfile = Tempfile.new("bind")
        File.open(tempfile, 'w') do |file|
          build_bind_main_partial(file)
          build_bind_zone_partial(file)

          file.respond_to?(:flush) and file.flush
        end

        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} #{bind_conf}))
      end

      def bind_setup
        bind_setup_template = File.join(self.class.template_dir, 'bind-setup.erb')
        self.ssh.bootstrap(ZTK::Template.render(bind_setup_template))

        build_bind_conf

        self.ssh.exec(%(sudo /bin/bash -c 'service bind9 restart || service bind9 start'))
      end

    end

  end
end
