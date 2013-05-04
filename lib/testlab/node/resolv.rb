class TestLab
  class Node

    module Resolv
      require 'tempfile'

      # Builds the main resolv configuration sections
      def build_resolv_main_conf(file)
        resolv_conf_template = File.join(self.class.template_dir, "resolv.erb")

        context = {
          :servers => [TestLab::Network.ips, "8.8.8.8", "8.8.4.4" ].flatten,
          :search => TestLab::Container.domains.join(' ')
        }

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} RESOLVER Configuration"))
        file.puts(ZTK::Template.render(resolv_conf_template, context))
      end

      def build_resolv_conf
        self.ssh.file(:target => File.join("/etc/resolv.conf"), :chown => "root:root") do |file|
          build_resolv_main_conf(file)
        end
      end

    end

  end
end
