class TestLab
  module Support

    # Execution Support Module
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module Execution

      # Bootstrap
      #
      # Renders the supplied content into a file over the SSH connection and
      # executes it as the 'root' user.
      def bootstrap(content, options={})
        ssh.bootstrap(content, options)
      end

      # Execute
      #
      # Executes the supplied command over the SSH connection.
      def exec(command, options={})
        ssh.exec(command, options)
      end

      # File
      #
      # Renders the supplied file over the SSH connection.
      def file(options={}, &block)
        ssh.file(options, &block)
      end

      # Uploads
      #
      # Uploads the supplied file over the SSH connection.
      def upload(local, remote, options={})
        ssh.upload(local, remote, options)
      end

      # Download
      def download(remote, local, options={})
        ssh.download(remote, local, options)
      end

    end

  end
end
