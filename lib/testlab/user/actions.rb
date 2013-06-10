class TestLab
  class User

    module Actions

      # Create the user
      #
      # @return [Boolean] True if successful.
      def create
        @ui.logger.debug { "User Create: #{self.id} " }

        node_home_dir = ((self.container.node.user == "root") ? %(/root) : %(/home/#{self.container.node.user}))
        node_authkeys = File.join(node_home_dir, ".ssh", "authorized_keys")

        user_home_dir = File.join(self.container.lxc.fs_root, ((self.id == "root") ? %(/root) : %(/home/#{self.id})))
        user_authkeys = File.join(user_home_dir, ".ssh", "authorized_keys")
        user_authkeys2 = File.join(user_home_dir, ".ssh", "authorized_keys2")

        # ensure the container user exists
        container_passwd_file = File.join(self.container.lxc.fs_root, "etc", "passwd")
        if self.container.node.ssh.exec(%(sudo grep "#{self.id}" #{container_passwd_file}), :ignore_exit_status => true).exit_code != 0

          if !self.gid.nil?
            groupadd_command = %(groupadd --gid #{self.gid} #{self.id})
            self.container.node.ssh.exec(%(sudo chroot #{self.container.lxc.fs_root} /bin/bash -c '#{groupadd_command}'))
          end

          useradd_command = %W(useradd --create-home --shell /bin/bash --groups sudo --password #{self.password})
          useradd_command << "--uid #{self.uid}" if !self.uid.nil?
          useradd_command << "--gid #{self.gid}" if !self.gid.nil?
          useradd_command << self.id
          useradd_command = useradd_command.flatten.compact.join(' ')

          self.container.node.ssh.exec(%(sudo chroot #{self.container.lxc.fs_root} /bin/bash -c '#{useradd_command}'))
        end

        # ensure the user user gets our node user key
        authkeys = {
          node_authkeys => user_authkeys,
          node_authkeys => user_authkeys2
        }

        authkeys.each do |source, destination|
          self.container.node.ssh.exec(%(sudo mkdir -pv #{File.dirname(destination)}))
          self.container.node.ssh.exec(%(sudo cp -v #{source} #{destination}))
          self.container.node.ssh.exec(%(sudo chmod -v 644 #{destination}))
        end

        true
      end

      # Up the user
      #
      # @return [Boolean] True if successful.
      def up
        @ui.logger.debug { "User Up: #{self.id}" }

        # ensure the container user home directory is owned by them
        home_dir = self.container.lxc.attach(%(-- /bin/bash -c 'grep #{self.id} /etc/passwd | cut -d ":" -f6')).strip
        self.container.lxc.attach(%(-- /bin/bash -c 'sudo chown -Rv $(id -u #{self.id}):$(id -g #{self.id}) #{home_dir}'))

        # ensure the sudo user group can do passwordless sudo
        self.container.lxc.attach(%(-- /bin/bash -c 'grep "sudo\tALL=\(ALL:ALL\) ALL" /etc/sudoers && sed -i "s/sudo\tALL=\(ALL:ALL\) ALL/sudo\tALL=\(ALL:ALL\) NOPASSWD: ALL/" /etc/sudoers'))
      end

    end

  end
end
