class TestLab

  class Provisioner

    # Shell Provisioner Error Class
    class ShellError < ProvisionerError; end

    # Shell Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Shell
      require 'tempfile'

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui || TestLab.ui)

        @config[:shell] ||= "/bin/bash"
      end

      # Shell Provisioner Container Setup
      #
      # Renders the defined script to a temporary file on the target container
      # and proceeds to execute said script as root via *lxc-attach*.
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def setup(container)
        if !@config[:setup].nil?
          ZTK::RescueRetry.try(:tries => 2, :on => ShellError) do
            tempfile = Tempfile.new("bootstrap")
            container.node.ssh.file(:target => File.join(container.lxc.fs_root, tempfile.path), :chmod => '0777', :chown => 'root:root') do |file|
              file.puts(@config[:setup])
            end
            if container.lxc.attach(@config[:shell], tempfile.path) =~ /No such file or directory/
              raise ShellError, "We could not find the bootstrap file!"
            end
          end
        end

        true
      end

      # Shell Provisioner Container Teardown
      #
      # This is a NO-OP currently.
      #
      # @return [Boolean] True if successful.
      def teardown(container)
        # NOOP

        true
      end

    end

  end
end
