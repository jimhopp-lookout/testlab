class TestLab

  # Container Error Class
  class ContainerError < TestLabError; end

  # Container Class
  #
  # @author Zachary Patten <zachary@jovelabs.net>
  class Container < ZTK::DSL::Base
    belongs_to  :node,        :class_name => 'TestLab::Node'

    attribute   :provisioner
    attribute   :config

    attribute   :interfaces

    attribute   :distro
    attribute   :release
    attribute   :arch

    attribute   :persist

    def initialize(*args)
      super(*args)

      @ui          = TestLab.ui
      @provisioner = self.provisioner.new(self.config) if !self.provisioner.nil?
    end

    # Our LXC Container class
    def lxc
      @lxc ||= self.node.lxc.container(self.id)
    end

    # Create the container
    def create
      @ui.logger.debug { "Container Create: #{self.id} " }

      self.arch ||= detect_arch
      self.lxc.create(*create_args)
    end

    # Destroy the container
    def destroy
      @ui.logger.debug { "Container Destroy: #{self.id} " }

      self.down
      self.lxc.destroy
    end

    # Start the container
    def up
      @ui.logger.debug { "Container Up: #{self.id} " }

      if !self.lxc.exists?
        self.create
      end
      self.lxc.start
    end

    # Stop the container
    def down
      @ui.logger.debug { "Container Down: #{self.id} " }

      self.lxc.stop
    end

    # Reload the container
    def reload
      self.down
      self.up
    end

    # State of the container
    def state
      self.lxc.state
    end

    # Container Callback: after_up
    def after_up
      @ui.logger.debug { "Container Callback: After Up: #{self.id} " }
      self.create
      self.up
    end

    # Container Callback: before_down
    def before_down
      @ui.logger.debug { "Container Callback: Before Down: #{self.id} " }
      self.down
    end

    # Method missing handler
    def method_missing(method_name, *method_args)
      @ui.logger.debug { "CONTAINER METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

      if (defined?(@provisioner) && @provisioner.respond_to?(method_name))
        @provisioner.send(method_name, [self, *method_args].flatten)
      else
        super(method_name, *method_args)
      end
    end

  private

    # Returns arguments for lxc-create based on our distro
    def create_args
      case self.distro.downcase
      when "ubuntu" then
        %(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release} --arch #{arch})
      when "fedora" then
        %(-f /etc/lxc/#{self.id} -t #{self.distro} -- --release #{self.release})
      end
    end

    # Attempt to detect the architecture of the node our container is running on
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
