class TestLab
  class Container

    module Execution

      # Container Bootstrap
      #
      # Renders the supplied content into a file on the container and proceeds
      # to execute it on the container as root.
      #
      # @param [String] content The content to render on the container and
      #   execute.  This is generally a bash script of some sort for example.
      # @return [String] The output of respective SSH/LXC bootstrap.
      def bootstrap(content, options={})
        if self.lxc_clone.exists?
          self.ssh.bootstrap(content, options)
        else
          self.lxc.bootstrap(content)
        end
      end

      # Container Execute
      #
      # Executes the supplied command on the container.
      def exec(command, options={})
        self.ssh.exec(command, options)
      end

    end

  end
end
