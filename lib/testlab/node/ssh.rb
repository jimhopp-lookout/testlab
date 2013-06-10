class TestLab
  class Node

    module SSH

      # SSH to the Node
      def ssh(options={})
        if (!defined?(@ssh) || @ssh.nil?)
          @ssh ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200, :silence => true}.merge(options))
          @ssh.config do |c|
            c.host_name = @provider.ip
            c.port      = @provider.port
            c.user      = @provider.user
            c.keys      = @provider.identity
          end
        end
        @ssh
      end

      # SSH to a container running on the Node
      def container_ssh(container, options={})
        name = container.id
        @container_ssh ||= Hash.new
        if @container_ssh[name].nil?
          @container_ssh[name] ||= ZTK::SSH.new({:ui => @ui, :timeout => 1200, :silence => true}.merge(options))
          @container_ssh[name].config do |c|
            c.proxy_host_name = @provider.ip
            c.proxy_port      = @provider.port
            c.proxy_user      = @provider.user
            c.proxy_keys      = @provider.identity

            c.host_name       = container.ip

            c.user            = (options[:user]   || container.primary_user.id)
            c.password        = (options[:passwd] || container.primary_user.password)
            c.keys            = (options[:keys]   || container.primary_user.keys || @provider.identity)
          end
        end
        @container_ssh[name]
      end

    end

  end
end
