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
          self.to_ephemeral
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
          self.to_static
        end

        true
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
      def to_static
        if self.lxc_clone.exists?
          self.lxc.stop
          self.lxc.destroy(%(-f))

          self.lxc_clone.stop
          self.lxc_clone.clone(%W(-o #{self.lxc_clone.name} -n #{self.lxc.name}))
          self.lxc_clone.destroy(%(-f))

          build_lxc_config(self.lxc.config)
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
        if (self.lxc.exists? && !self.lxc_clone.exists?)
          self.lxc_clone.stop
          self.lxc_clone.destroy(%(-f))

          self.lxc.stop
          self.lxc.clone(%W(-o #{self.lxc.name} -n #{self.lxc_clone.name}))
          self.lxc.destroy(%(-f))

          build_lxc_config(self.lxc_clone.config)
        else
          self.lxc.stop
          self.persist and self.lxc.destroy(%(-f))
        end

        true
      end

    end

  end
end
