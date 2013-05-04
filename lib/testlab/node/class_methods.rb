class TestLab
  class Node

    module ClassMethods

      # Returns the path to the node templates
      def template_dir
        File.join(TestLab.gem_dir, "lib", "testlab", "node", "templates")
      end

    end

  end
end
