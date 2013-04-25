class TestLab
  class Container

    module Args

      # Returns arguments for lxc-create based on our distro
      def create_args
        case self.distro.downcase
        when "ubuntu" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release} --arch #{arch})
        when "fedora" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release})
        end
      end

    end

  end
end
