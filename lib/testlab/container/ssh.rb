class TestLab
  class Container

    module SSH

      # ZTK:SSH object
      #
      # Returns a *ZTK:SSH* class instance configured for this container.
      #
      # @return [ZTK::SSH] An instance of ZTK::SSH configured for this
      #   container.
      def ssh(options={})
        self.node.container_ssh(self, options)
      end

    end

  end
end
