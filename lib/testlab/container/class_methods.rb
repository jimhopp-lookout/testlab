class TestLab
  class Container

    module ClassMethods

      # Container domain list
      #
      # Returns an array of strings containing all the unique domains defined
      # across all containers
      #
      # @return [Array<String>] A unique array of all defined domain names.
      def domains
        self.all.select{ |container| (!container.template rescue true) }.map do |container|
          container.domain ||= container.node.domain
          container.domain
        end.compact.uniq
      end

    end

  end
end
