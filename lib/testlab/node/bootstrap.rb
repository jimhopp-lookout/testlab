class TestLab
  class Node

    module Bootstrap

      def bootstrap
        node_bootstrap_template = File.join(self.class.template_dir, 'bootstrap.erb')
        self.ssh.bootstrap(ZTK::Template.render(node_bootstrap_template))
      end

    end

  end
end
