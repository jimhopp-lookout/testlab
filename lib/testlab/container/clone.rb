class TestLab
  class Container

    module Clone

      # Put the container into an ephemeral state.
      #
      # Prepares the container, if needed, for ephemeral cloning.
      #
      # @return [Boolean] True if successful.
      def ephemeral
        @ui.logger.debug { "Container Ephemeral: #{self.id}" }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Ephemeral', :yellow)) do
          is_persistent? and self.to_ephemeral
        end

        true
      end

      # Put the container into a persistent state.
      #
      # Prepares the container, if needed, for persistance.
      #
      # @return [Boolean] True if successful.
      def persistent
        @ui.logger.debug { "Container Persistent: #{self.id}" }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Persistent', :yellow)) do
          is_ephemeral? and self.to_persistent
        end

        true
      end

      # Persistent Operation Check
      #
      # Checks if the container is operating in ephemeral mode, and if it is
      # raises an exception indicating the operation can not proceed.
      #
      # If the container is operating in persistent mode, no output is generated
      # and true is returned indicating the operation can continue.
      #
      # @return [Boolean] True if the operation can continue; false otherwise.
      def persistent_operation_check(action)
        if is_ephemeral?
          raise ContainerError, "You can not #{action} #{self.id} because it is currently in ephemeral mode!"
        end

        true
      end

      # Is Container Ephemeral?
      #
      # Returns true if the container is in ephemeral mode, false otherwise.
      #
      # @return [Boolean] Returns true if the container is ephemeral, false
      #   otherwise.
      def is_ephemeral?
        self.lxc_clone.exists?
      end

      # Is Container Persistent?
      #
      # Returns true if the container is in persistent mode, false otherwise.
      #
      # @return [Boolean] Returns true if the container is persistent, false
      #   otherwise.
      def is_persistent?
        !is_ephemeral?
      end

      # LXC::Container object
      #
      # Returns a *LXC::Container* class instance configured for the clone of
      # this container.
      #
      # @return [LXC] An instance of LXC::Container configured for the clone of
      #   this container.
      def lxc_clone
        @lxc_clone ||= self.node.lxc.container("#{self.id}-master")
      end

      # Convert to Static Container
      #
      # If the current container is operating as an ephemeral container, this
      # will convert it back to a static container, otherwise no changes will
      # occur.
      #
      # @return [Boolean] Returns true if successful.
      def to_persistent
        if self.is_ephemeral?
          self_state = self.state

          configure

          self.lxc.stop
          self.lxc.destroy(%(-f))

          self.lxc_clone.stop
          self.lxc_clone.clone(%W(-o #{self.lxc_clone.name} -n #{self.lxc.name}))
          self.lxc_clone.destroy(%(-f))

          # bring our container back online if it was running before the operation
          (self_state == :running) and self.up
        end

        true
      end

      # Convert to Ephemeral Container
      #
      # If the current container is operating as a static container, this will
      # convert it to a ephemeral container, otherwise no changes will occur.
      #
      # @return [Boolean] Returns true if successful.
      def to_ephemeral
        if self.is_persistent?
          self_state = self.state

          configure

          self.lxc_clone.stop
          self.lxc_clone.destroy(%(-f))

          self.lxc.stop
          self.lxc.clone(%W(-o #{self.lxc.name} -n #{self.lxc_clone.name}))
          self.lxc.destroy(%(-f))

          # bring our container back online if it was running before the operation
          (self_state == :running) and self.up
        end

        true
      end

    end

  end
end
