class TestLab
  class Node

    module DHCPD

      # Builds the main DHCPD configuration sections
      def build_dhcpd_main_conf(file)
        dhcpd_conf_template = File.join(self.class.template_dir, "dhcpd.conf.erb")

        # f.puts(Cucumber::Chef.generate_do_not_edit_warning("DHCPD Configuration"))
        file.puts(ZTK::Template.render(dhcpd_conf_template, {}))
      end

      # Builds the DHCPD configuration sections for our networks
      def build_dhcpd_networks_conf(file)
        TestLab::Network.all.each do |network|
          dhcpd_network_template = File.join(self.class.template_dir, 'dhcpd-network.erb')

          context = {
            :gateway => network.clean_ip,
            :network => network.network,
            :netmask => network.netmask,
            :broadcast => network.broadcast,
            :arpa => network.arpa
          }

          file.puts
          file.puts(ZTK::Template.render(dhcpd_network_template, context))
        end
      end

      # Builds the DHCPD configuration sections for our hosts (i.e. containers)
      def build_dhcpd_hosts_conf(file)
        dhcpd_host_template = File.join(self.class.template_dir, 'dhcpd-host.erb')

        TestLab::Container.all.each do |container|
          interface = (container.interfaces.find{ |i,c| c[:primary] == true }.last rescue container.interfaces.first.last)

          interface[:name] ||= "eth0"
          interface[:ip]   ||= container.send(:generate_ip)
          interface[:mac]  ||= container.send(:generate_mac)

          context = {
            :id => container.id,
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
          build_dhcpd_networks_conf(file)
          build_dhcpd_hosts_conf(file)

          file.respond_to?(:flush) and file.flush
        end

        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} #{dhcpd_conf}))

        self.ssh.exec(%(sudo service isc-dhcp-server restart))
      end

    end

  end
end
