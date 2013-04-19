class TestLab

  class Provider

    # Vagrant Provider Error Class
    class VagrantError < ProviderError; end

    # Vagrant Provider Class
    #
    # @author Zachary Patten <zachary@jovelabs.net>
    class Vagrant

      # States which indicate the VM is running
      RUNNING_STATES      = %w(running).map(&:to_sym)

      # States which indicate the VM is shut down
      SHUTDOWN_STATES     = %w(aborted paused saved poweroff).map(&:to_sym)

      # The state we report if we can not determine the VM state
      UNKNOWN_STATE       = :unknown

      # A collection of all valid states the VM can be in
      VALID_STATES        = (RUNNING_STATES + SHUTDOWN_STATES).flatten

      # A collection of all invalid states the VM can be in
      INVALID_STATES      = (%w(not_created).map(&:to_sym) + [UNKNOWN_STATE]).flatten

      # A collection of all states the VM can be in
      ALL_STATES          = (VALID_STATES + INVALID_STATES).flatten

      MSG_NO_LAB          = %(We could not find a test lab!)

      def initialize(config={}, ui=nil)
        @config   = config
        @ui       = (ui || TestLab.ui)
      end

################################################################################

      # Create the Vagrant instance
      def create
        @ui.logger.debug { "@config == #{@config.inspect}" }

        klass = self.class.to_s.split('::').last
        @ui.logger.debug { "klass == #{klass.inspect}" }

        ZTK::Benchmark.bench(:message => "Creating #{klass} instance", :mark => "completed in %0.4f seconds.", :ui => @ui) do
          vagrantfile_template  = File.join(TestLab.gem_dir, "lib", "testlab", "providers", "templates", klass.downcase, "Vagrantfile.erb")
          vagrantfile           = File.join(@config[:repo], "Vagrantfile")
          IO.write(vagrantfile, ZTK::Template.render(vagrantfile_template, @config))

          self.vagrant_cli("up", id)
          ZTK::TCPSocketCheck.new(:host => self.ip, :port => self.port, :wait => 120).wait
        end

        self.state
      end

      # Destroy Vagrant-controlled VM
      def destroy
        !self.exists? and raise VagrantError, MSG_NO_LAB

        self.vagrant_cli("destroy", "--force", id)

        self.state
      end

################################################################################

      # Online Vagrant-controlled VM
      def up
        !self.exists? and raise VagrantError, MSG_NO_LAB

        self.vagrant_cli("up", id)
        ZTK::TCPSocketCheck.new(:host => self.ip, :port => self.port, :wait => 120).wait

        self.state
      end

      # Halt Vagrant-controlled VM
      def down
        !self.exists? and raise VagrantError, MSG_NO_LAB

        self.vagrant_cli("halt", id)

        self.state
      end

################################################################################

      # Reload Vagrant-controlled VM
      def reload
        self.down
        self.up

        self.state
      end

################################################################################

      # Inquire the state of the Vagrant-controlled VM
      def state
        output = self.vagrant_cli("status | grep '#{id}'").output
        result = UNKNOWN_STATE
        ALL_STATES.map{ |s| s.to_s.gsub('_', ' ') }.each do |state|
          if output =~ /#{state}/
            result = state.to_s.gsub(' ', '_')
            break
          end
        end
        result.to_sym
      end

################################################################################

      # Does the Vagrant-controlled VM exist?
      def exists?
        (self.state != :not_created)
      end

      # Is the Vagrant-controlled VM alive?
      def alive?
        (self.exists? && (RUNNING_STATES.include?(self.state) rescue false))
      end

      # Is the Vagrant-controlled VM dead?
      def dead?
        !self.alive?
      end

################################################################################

      def id
        (@config[:vagrant][:id] || "testlab-#{ENV['USER']}".downcase)
      end

      def user
        "vagrant"
      end

      def ip
        "192.168.33.10"
      end

      def port
        22
      end

################################################################################

      def vagrant_cli(*args)
        command = TestLab.build_command("vagrant", *args)
        ZTK::Command.new.exec(command, :silence => true)
      end

################################################################################


    end

  end
end
