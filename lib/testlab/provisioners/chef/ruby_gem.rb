class TestLab
  class Provisioner
    class Chef

      # RubyGem Provisioner Error Class
      class RubyGemError < ChefError; end

      # RubyGem Provisioner Class
      #
      # @author Zachary Patten <zachary AT jovelabs DOT com>
      class RubyGem
        require 'json'

        def initialize(config={}, ui=nil)
          @config = (config || Hash.new)
          @ui     = (ui || TestLab.ui)

          @ui.logger.debug { "config(#{@config.inspect})" }
        end

        # RubyGem Provisioner Container Setup
        #
        # Renders the defined script to a temporary file on the target container
        # and proceeds to execute said script as root via *lxc-attach*.
        #
        # @param [TestLab::Container] container The container which we want to
        #   provision.
        # @return [Boolean] True if successful.
        def on_container_setup(container)
          # NOOP

          true
        end

        # RubyGem Provisioner Container Teardown
        #
        # This is a NO-OP currently.
        #
        # @return [Boolean] True if successful.
        def on_container_teardown(container)
          # NOOP

          true
        end

      end

    end
  end
end
