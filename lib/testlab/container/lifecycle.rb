class TestLab
  class Container

    module Lifecycle

      # Setup the container
      #
      # Attempts to setup the container.  We first create the container, then
      # attempt to bring it online.  Afterwards the containers provisioner is
      # called.
      #
      # @return [Boolean] True if successful.
      def setup
        @ui.logger.debug { "Container Setup: #{self.id} " }

        self.create
        self.up

        please_wait(:ui => @ui, :message => format_object_action(self, 'Setup', :green)) do

          self.users.each do |user|
            user.setup
          end

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> PROVISIONER SETUP #{provisioner} <<<<<" }
            provisioner.new(self.config, @ui).setup(self)
          end

        end

        true
      end

      # Teardown the container
      #
      # Attempts to teardown the container.  We first call the provisioner
      # teardown method defined for the container, if any.  Next we attempt to
      # offline the container.  Afterwards the container is destroy.
      #
      # @return [Boolean] True if successful.
      def teardown
        @ui.logger.debug { "Container Teardown: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Teardown', :red)) do

          self.provisioners.each do |provisioner|
            @ui.logger.info { ">>>>> PROVISIONER TEARDOWN #{provisioner} <<<<<" }
            provisioner.new(self.config, @ui).teardown(self)
          end

        end

        self.down
        self.destroy

        true
      end

    end

  end
end
