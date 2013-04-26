class TestLab
  class Node

    module LXC
      require 'lxc'

      # Returns the LXC object for this Node
      #
      # This object is used to control containers on the node via it's provider
      def lxc(options={})
        if (!defined?(@lxc) || @lxc.nil?)
          @lxc ||= ::LXC.new
          @lxc.use_sudo = true
          @lxc.use_ssh = self.ssh
        end
        @lxc
      end

      # Returns the machine type of the node.
      #
      # @return [String] The output of 'uname -m'.
      def arch
        @arch ||= self.ssh.exec(%(uname -m)).output.strip
      end

    end

  end
end
