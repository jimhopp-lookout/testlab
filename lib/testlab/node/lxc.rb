class TestLab
  class Node

    module LXC
      require 'lxc'

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
        @arch ||= self.exec(%(uname -m)).output.strip
      end

    end

  end
end
