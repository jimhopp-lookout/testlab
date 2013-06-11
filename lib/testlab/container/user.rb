class TestLab
  class Container

    module User

      # Container primary user
      #
      # Returns the primary user for the container.  If the container has
      # multiple users, this is based on which ever user is marked
      # with the primary flag.  If the container only has one user, then
      # it is returned.
      #
      # @return [TestLab::User] The primary user for the container.
      def primary_user
        if self.users.count == 0
          case self.distro.downcase
          when 'ubuntu' then
            u = TestLab::User.new "ubuntu" do
              password 'ubuntu'
            end
            u.container = self
          end
        elsif self.users.any?{ |u| u.primary == true }
          self.users.find{ |u| u.primary == true }
        else
          self.users.first
        end
      end

    end

  end
end
