class TestLab
  class Container

    module IO

      # Export the container
      #
      # @return [Boolean] True if successful.
      def export(compression=9)
        @ui.logger.debug { "Container Export: #{self.id} " }

        (self.lxc.state == :not_created) and return false

        self.down

        sc_file = File.join("/", "tmp", "#{self.id}.sc")
        local_file = File.join(Dir.pwd, File.basename(sc_file))

        please_wait(:ui => @ui, :message => format_object_action(self, 'Compress', :blue)) do
          script = <<-EOF
set -x
find #{self.lxc.container_root} -print0 -depth | cpio -o0 | pbzip2 -#{compression} -vfcz > #{sc_file}
chown ${SUDO_USER}:${SUDO_USER} #{sc_file}
EOF
          self.node.ssh.bootstrap(script)
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Export', :blue)) do
          self.node.ssh.download(sc_file, local_file)
        end

        puts("Your shipping container is now exported and available at '#{local_file}'.")

        true
      end

      # Import the container
      #
      # @return [Boolean] True if successful.
      def import(local_file)
        @ui.logger.debug { "Container Import: #{self.id} " }

        self.down
        self.destroy

        sc_file = File.join("/", "tmp", "#{self.id}.sc")

        please_wait(:ui => @ui, :message => format_object_action(self, 'Import', :blue)) do
          self.node.ssh.exec(%(sudo rm -fv #{sc_file}), :silence => true, :ignore_exit_status => true)
          self.node.ssh.upload(local_file, sc_file)
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Expand', :blue)) do
          script = <<-EOF
set -x
pbzip2 -vdc #{sc_file} | cpio -uid && rm -fv #{sc_file}
EOF
          self.node.ssh.bootstrap(script)
        end

        true
      end

    end

  end
end
