class TestLab
  class Container

    module LXC

      # Our LXC Container class
      #
      # @return [LXC] An instance of LXC::Container configured for this
      #   container.
      def lxc
        @lxc ||= self.node.lxc.container(self.id)
      end

    end

  end
end
