class TestLab
  class Container

    module ClassMethods

      def domains
        self.all.map do |container|
          container.domain ||= container.node.labfile.config[:domain]
          container.domain
        end.compact
      end

    end

  end
end
