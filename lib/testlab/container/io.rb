class TestLab
  class Container

    module IO
      PBZIP2_MEMORY = 256

      # Export the container
      #
      # @return [Boolean] True if successful.
      def export(compression=9, local_file=nil)
        @ui.logger.debug { "Container Export: #{self.id} " }

        (self.lxc.state == :not_created) and return false

        self.down

        sc_file = File.join("/", "tmp", "#{self.id}.sc")
        local_file ||= File.join(Dir.pwd, File.basename(sc_file))

        please_wait(:ui => @ui, :message => format_object_action(self, 'Compress', :cyan)) do
          self.node.ssh.bootstrap(<<-EOF)
set -x
set -e

du -sh #{self.lxc.container_root}
find #{self.lxc.container_root} -print0 -depth | cpio -o0 | pbzip2 -#{compression} -vfczm#{PBZIP2_MEMORY} > #{sc_file}
chown ${SUDO_USER}:${SUDO_USER} #{sc_file}
ls -lah #{sc_file}
EOF
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Export', :cyan)) do
          File.exists?(local_file) and FileUtils.rm_f(local_file)
          self.node.ssh.download(sc_file, local_file)
        end

        puts("Your shipping container is now exported and available at '#{local_file}'!")

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

        please_wait(:ui => @ui, :message => format_object_action(self, 'Import', :cyan)) do
          self.node.ssh.exec(%(sudo rm -fv #{sc_file}), :silence => true, :ignore_exit_status => true)
          self.node.ssh.upload(local_file, sc_file)
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Expand', :cyan)) do
          self.node.ssh.bootstrap(<<-EOF)
set -x
set -e

ls -lah #{sc_file}
pbzip2 -vdcm#{PBZIP2_MEMORY} #{sc_file} | cpio -uid && rm -fv #{sc_file}
du -sh #{self.lxc.container_root}
EOF
        end

        puts("Your shipping container is now imported and available for use!")

        true
      end

    end

  end
end
