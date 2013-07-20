class TestLab
  class Node

    module Execution

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

    end

  end
end
