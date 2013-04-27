class TestLab
  class Node

    module DHCPD
      require 'tempfile'

      # Builds the main DHCPD configuration sections
      def build_dhcpd_main_conf(file)
        dhcpd_conf_template = File.join(self.class.template_dir, "dhcpd.erb")

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} DHCPD Configuration"))

        context = {}

        file.puts(ZTK::Template.render(dhcpd_conf_template, context))
      end

      # Builds the DHCPD configuration sections for our zones
      def build_dhcpd_zone_conf(file)
        dhcpd_zone_template = File.join(self.class.template_dir, 'dhcpd-zone.erb')

        TestLab::Network.all.each do |network|
          context = {
            :zone => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(dhcpd_zone_template, context))
        end

        tlds = ([self.labfile.config[:tld]] + TestLab::Container.tlds).flatten
        tlds.each do |tld|
          context = {
            :zone => tld
          }

          file.puts
          file.puts(ZTK::Template.render(dhcpd_zone_template, context))
        end
      end

      # Builds the DHCPD configuration sections for our subnets
      def build_dhcpd_subnet_conf(file)
        dhcpd_subnet_template = File.join(self.class.template_dir, 'dhcpd-subnet.erb')

        TestLab::Network.all.each do |network|
          context = {
            :gateway => network.clean_ip,
            :network => network.network,
            :netmask => network.netmask,
            :broadcast => network.broadcast
          }

          file.puts
          file.puts(ZTK::Template.render(dhcpd_subnet_template, context))
        end
      end

      # Builds the DHCPD configuration sections for our hosts (i.e. containers)
      def build_dhcpd_host_conf(file)
        dhcpd_host_template = File.join(self.class.template_dir, 'dhcpd-host.erb')

        TestLab::Container.all.each do |container|
          interface = container.primary_interface.last

          context = {
            :id => container.id,
            :tld => (container.tld || self.labfile.config[:tld]),
            :ip => interface[:ip].split('/').first,
            :mac => interface[:mac]
          }

          file.puts
          file.puts(ZTK::Template.render(dhcpd_host_template, context))
        end
      end

      # Build our DHCPD configuration file, push it to the node, kick DHCPD
      def build_dhcpd_conf
        dhcpd_conf = File.join("/etc/dhcp/dhcpd.conf")

        tempfile = Tempfile.new("dhcpd")
        File.open(tempfile, 'w') do |file|
          build_dhcpd_main_conf(file)
          build_dhcpd_zone_conf(file)
          build_dhcpd_subnet_conf(file)
          build_dhcpd_host_conf(file)

          file.respond_to?(:flush) and file.flush
        end

        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} #{dhcpd_conf}))

        self.ssh.exec(%(sudo service isc-dhcp-server restart))
      end

    end

  end
end
