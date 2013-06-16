class TestLab
  class Container

    module SSH

      # ZTK:SSH object
      #
      # Returns a *ZTK:SSH* class instance configured for this container.
      #
      # @return [ZTK::SSH] An instance of ZTK::SSH configured for this
      #   container.
      def ssh(options={})
        self.node.container_ssh(self, options)
      end

      # Returns text suitable for use in an SSH configuration file
      #
      # @return [String] SSH configuration text blob.
      def ssh_config
        identities = [self.users.map(&:identity), self.node.identity].flatten.compact.uniq

        output = <<-EOF
#{ZTK::Template.do_not_edit_notice(:message => %(TestLab "#{self.fqdn}" SSH Configuration))}
Host #{self.id}
  HostName #{self.ip}
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  ForwardAgent no
  IdentitiesOnly yes
EOF

        identities.each do |identity|
          output += "  IdentityFile #{identity}\n"
        end

        output
      end

    end

  end
end
