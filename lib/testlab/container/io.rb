class TestLab
  class Container

    module IO
      require 'tempfile'
      PBZIP2_MEMORY = 256

      # Export the container
      #
      # @return [Boolean] True if successful.
      def export(compression=9, local_file=nil)
        @ui.logger.debug { "Container Export: #{self.id} " }

        (self.lxc.state == :not_created) and return false

        self.down

        export_tempfile = Tempfile.new('export')
        remote_filename = File.basename(export_tempfile.path.dup)
        export_tempfile.close!

        remote_file  = File.join("", "tmp", remote_filename)
        local_file ||= File.join(Dir.pwd, File.basename(remote_file))
        local_file   = File.expand_path(local_file)
        root_fs_path = self.lxc.fs_root.split(File::SEPARATOR).last

        please_wait(:ui => @ui, :message => format_object_action(self, 'Compress', :cyan)) do
          self.node.ssh.bootstrap(<<-EOF)
set -x
set -e

du -sh #{self.lxc.container_root}
cd #{self.lxc.container_root}
find #{root_fs_path} -depth -print0 | cpio -o0 | pbzip2 -#{compression} -vfczm#{PBZIP2_MEMORY} > #{remote_file}
chown ${SUDO_USER}:${SUDO_USER} #{remote_file}
ls -lah #{remote_file}
EOF
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Export', :cyan)) do
          File.exists?(local_file) and FileUtils.rm_f(local_file)
          self.node.ssh.download(remote_file, local_file)
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
        self.create

        import_tempfile = Tempfile.new('import')
        remote_filename = File.basename(import_tempfile.path.dup)
        import_tempfile.close!

        remote_file  = File.join("", "tmp", remote_filename)
        local_file   = File.expand_path(local_file)
        root_fs_path = self.lxc.fs_root.split(File::SEPARATOR).last

        please_wait(:ui => @ui, :message => format_object_action(self, 'Import', :cyan)) do
          self.node.ssh.exec(%(sudo rm -fv #{remote_file}), :silence => true, :ignore_exit_status => true)
          self.node.ssh.upload(local_file, remote_file)
        end

        please_wait(:ui => @ui, :message => format_object_action(self, 'Expand', :cyan)) do
          self.node.ssh.bootstrap(<<-EOF)
set -x
set -e

ls -lah #{remote_file}
cd #{self.lxc.container_root}
rm -rf #{root_fs_path}
pbzip2 -vdcm#{PBZIP2_MEMORY} #{remote_file} | cpio -uid && rm -fv #{remote_file}
du -sh #{self.lxc.container_root}
EOF
        end

        puts("Your shipping container is now imported and available for use!")

        true
      end

    end

  end
end
