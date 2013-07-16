class TestLab

  class Provider

    # Local Provider Error Class
    class LocalError < ProviderError; end

    # Local Provider Class
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    class Local

      def initialize(config={}, ui=nil)
        @config = (config || Hash.new)
        @ui     = (ui     || TestLab.ui)

        # ensure our local key is there
        @config[:local] ||= Hash.new
      end

      # This is a NO-OP
      def create
        true
      end

      # This is a NO-OP
      def destroy
        true
      end

      # This is a NO-OP
      def up
        true
      end

      # This is a NO-OP
      def down
        true
      end

      # This is a NO-OP
      def reload
        self.down
        self.up

        true
      end

      # This is a NO-OP
      def state
        :running
      end

      # This is a NO-OP
      def exists?
        true
      end

      # This is a NO-OP
      def alive?
        true
      end

      # This is a NO-OP
      def dead?
        false
      end

      def instance_id
        TestLab.hostname
      end

      def user
        (@config[:local][:user] || ENV['USER'])
      end

      def identity
        (@config[:local][:identity] || File.join(ENV['HOME'], ".ssh", "id_rsa"))
      end

      def ip
        "127.0.0.1"
      end

      def port
        (@config[:local][:port] || 22)
      end

    end

  end
end
