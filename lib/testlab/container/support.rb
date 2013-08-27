class TestLab
  class Container

    module Support

      # Returns arguments for lxc-create based on our distro
      #
      # @return [Array<String>] An array of arguments for lxc-create
      def create_args
        case self.distro.downcase
        when "ubuntu" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release} --arch #{self.arch})
        when "fedora" then
          %W(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release})
        end
      end

      # Returns arguments for lxc-start
      #
      # @return [Array<String>] An array of arguments for lxc-start
      def start_args
        arguments = Array.new

        unless self.aa_profile.nil?
          arguments << %W(-s lxc.aa_profile="#{self.aa_profile}")
        end

        unless self.cap_drop.nil?
          cap_drop = [self.cap_drop].flatten.compact.map(&:downcase).join(' ')
          arguments << %W(-s lxc.cap.drop="#{cap_drop}")
        end

        arguments << %W(-d)

        arguments.flatten.compact
      end

      # Returns arguments for lxc-start-ephemeral
      #
      # @return [Array<String>] An array of arguments for lxc-start-ephemeral
      def clone_args
        arguments = Array.new

        arguments << %W(-o #{self.lxc_clone.name} -n #{self.lxc.name} -d)
        arguments << %W(--keep-data) if self.persist

        arguments.flatten.compact
      end

      # Attempt to detect the architecture of the node.  The value returned is
      # respective to the container distro.
      #
      # @return [String] The arch of the node in the context of the container
      #   distro
      def detect_arch
        case self.distro.downcase
        when "ubuntu" then
          ((self.node.arch =~ /x86_64/) ? "amd64" : "i386")
        when "fedora" then
          ((self.node.arch =~ /x86_64/) ? "amd64" : "i686")
        end
      end

    end

  end
end
