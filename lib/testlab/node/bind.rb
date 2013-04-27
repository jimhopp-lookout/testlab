class TestLab
  class Node

    module Bind
      require 'tempfile'

      # Builds the main bind configuration sections
      def build_bind_main_conf(file)
        bind_conf_template = File.join(self.class.template_dir, "bind.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND Configuration", :char => '//'))
        file.puts(ZTK::Template.render(bind_conf_template, {}))
      end

      # Builds the bind configuration sections for our zones
      def build_bind_zone_conf(file)
        bind_zone_template = File.join(self.class.template_dir, 'bind-zone.erb')

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(network.arpa)
        end

        tlds = ([self.labfile.config[:tld]] + TestLab::Container.tlds).flatten
        tlds.each do |tld|
          context = {
            :zone => tld
          }

          file.puts
          file.puts(ZTK::Template.render(bind_zone_template, context))

          build_bind_db(tld)
        end
      end

      def build_bind_db(zone)
        bind_db_template = File.join(self.class.template_dir, 'bind-db.erb')

        tempfile = Tempfile.new("bind-db")
        File.open(tempfile, 'w') do |file|
          file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} BIND DB File", :char => ';'))
          file.puts(ZTK::Template.render(bind_db_template, {}))
        end
        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} /var/lib/bind/db.#{zone}))
        self.ssh.exec(%(sudo rm -fv /var/lib/bind/db.#{zone}.jnl))
      end

      # Builds the BIND configuration
      def build_bind_conf
        bind_conf = File.join("/etc/bind/named.conf")
        tempfile = Tempfile.new("bind")
        File.open(tempfile, 'w') do |file|
          build_bind_main_conf(file)
          build_bind_zone_conf(file)

          file.respond_to?(:flush) and file.flush
        end

        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} #{bind_conf}))

        self.ssh.exec(%(sudo service bind9 restart))
      end

    end

  end
end
