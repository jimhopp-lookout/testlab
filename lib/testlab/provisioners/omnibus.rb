class TestLab

  class Provisioner

    # OmniBus Provisioner Error Class
    class OmniBusError < ProvisionerError; end

    # OmniBus Provisioner Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class OmniBus
      require 'tempfile'

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui || TestLab.ui)

        @config[:version]     ||= %(latest)
        @config[:omnibus_url] ||= %(http://www.opscode.com/chef/install.sh)
      end

      # OmniBus Provisioner Container Setup
      #
      # Renders the defined script to a temporary file on the target container
      # and proceeds to execute said script as root via *lxc-attach*.
      #
      # @param [TestLab::Container] container The container which we want to
      #   provision.
      # @return [Boolean] True if successful.
      def setup(container)
        omnibus_template = File.join(TestLab::Provisioner.template_dir, 'chef', 'omnibus.erb')
        container.bootstrap(ZTK::Template.render(omnibus_template, @config))
      end

      # OmniBus Provisioner Container Teardown
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
