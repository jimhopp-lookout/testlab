class TestLab
  class Node

    module LXC
      require 'lxc'

      # Node Bootstrap
      #
      # Renders the supplied content into a file on the node and proceeds
      # to execute it on the node as root.
      #
      # @param [String] content The content to render on the node and
      #   execute.  This is generally a bash script of some sort for example.
      # @return [String] The output of SSH bootstrap.
      def bootstrap(content, options={})
        self.ssh.bootstrap(content, options)
      end

      # Returns the LXC object for this Node
      #
      # This object is used to control containers on the node via it's provider
      #
      # @return [LXC] An instance of LXC configured for this node.
      def lxc(options={})
        if (!defined?(@lxc) || @lxc.nil?)
          @lxc_runner ||= ::LXC::Runner::SSH.new(:ui => @ui, :ssh => self.ssh)
          @lxc        ||= ::LXC.new(:ui => @ui, :runner => @lxc_runner)
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
