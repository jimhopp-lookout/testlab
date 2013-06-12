class TestLab

  class Provider

    # Local Provider Error Class
    class LocalError < ProviderError; end

    # Local Provider Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Local

################################################################################

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        # ensure our local key is there
        @config[:local] ||= Hash.new
      end

################################################################################

      # This is a NO-OP
      def create
        true
      end

      # This is a NO-OP
      def destroy
        true
      end

################################################################################

      # This is a NO-OP
      def up
        self.state
      end

      # This is a NO-OP
      def down
        self.state
      end

################################################################################

      # This is a NO-OP
      def reload
        self.down
        self.up

        self.state
      end

################################################################################

      # Inquire the state of the Local-controlled VM
      def state
        :running
      end

################################################################################

      # Does the Local-controlled VM exist?
      def exists?
        true
      end

      # Is the Local-controlled VM alive?
      def alive?
        true
      end

      # Is the Local-controlled VM dead?
      def dead?
        false
      end

      def instance_id
        %x(hostname).strip
      end

      def user
        ENV['USER']
      end

      def identity
        File.join(ENV['HOME'], ".ssh", "id_rsa")
      end

      def ip
        "127.0.0.1"
      end

      def port
        (@config[:local][:port] || 22)
      end

################################################################################

    end

  end
end
