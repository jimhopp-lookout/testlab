class TestLab
  class Container

    module ClassMethods

      def domains
        self.all.map(&:domain).compact
      end

    end

  end
end
