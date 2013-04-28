class TestLab
  class Node

    module Resolv
      require 'tempfile'

      # Builds the main resolv configuration sections
      def build_resolv_main_conf(file)
        resolv_conf_template = File.join(self.class.template_dir, "resolv.erb")

        tlds = ([self.labfile.config[:tld]] + TestLab::Container.tlds).flatten
        context = {
          :servers => [TestLab::Network.all.map(&:clean_ip), "8.8.8.8", "8.8.4.4" ].flatten,
          :search => tlds.join(' ')
        }

        file.puts(ZTK::Template.do_not_edit_notice(:message => "TestLab v#{TestLab::VERSION} RESOLVER Configuration"))
        file.puts(ZTK::Template.render(resolv_conf_template, context))
      end

      def build_resolv_conf
        resolv_conf = File.join("/etc/resolv.conf")
        tempfile = Tempfile.new("bind")
        File.open(tempfile, 'w') do |file|
          build_resolv_main_conf(file)

          file.respond_to?(:flush) and file.flush
        end

        self.ssh.upload(tempfile.path, File.basename(tempfile.path))
        self.ssh.exec(%(sudo mv -v #{File.basename(tempfile.path)} #{resolv_conf}))
      end

    end

  end
end
