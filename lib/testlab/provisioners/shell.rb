class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Shell
      require 'tempfile'

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui || TestLab.ui)

        @config[:shell] ||= "/bin/bash"
      end

      def setup(container)
        if !@config[:setup].nil?
          tempfile = Tempfile.new("bootstrap")
          container.node.ssh.file(:target => File.join(container.lxc.fs_root, tempfile.path), :chmod => '0777', :chown => 'root:root') do |file|
            file.puts(@config[:setup])
          end
          container.lxc.attach(@config[:shell], tempfile.path)
        end
      end

      def teardown(container)
        # NOOP
      end

    end

  end
end
