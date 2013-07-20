class TestLab
  module Utility

    # Misc Error Class
    class MiscError < UtilityError; end

    # Misc Module
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module Misc

      def format_object(object, color)
        klass = object.class.to_s.split('::').last

        ["#{klass}:".upcase.send(color).bold, "#{object.id}".white.bold].join(' ')
      end

      def format_object_action(object, action, color)
        klass = object.class.to_s.split('::').last

        ["#{klass}".downcase.send(color).bold, "#{object.id}".white.bold, "#{action}".downcase.send(color).bold, ].join(' ')
      end

      def format_message(message)
        "[".blue + "TL".blue.bold + "]".blue + " " + message
      end

      def please_wait(options={}, &block)
        ui      = options[:ui]
        message = options[:message]
        mark    = (options[:mark] || "# Completed in %0.4f seconds!".black.bold)

        !block_given? and raise MiscError, "You must supply a block!"
        ui.nil? and raise MiscError, "You must supply a ZTK::UI object!"
        message.nil? and raise MiscError, "You must supply a message!"

        message = format_message(message)
        length = message.uncolor.length
        max = (length >= 60 ? (length+1) : (60 - length))
        mark = ((' ' * max) + mark)

        ZTK::Benchmark.bench(:ui => ui, :message => message, :mark => mark) do
          yield
        end
      end

      def do_provisioner_callbacks(object, action, ui)
        klass       = object.class.to_s.split('::').last
        method_name = %(on_#{klass.downcase}_#{action.to_s.downcase}).to_sym

        object.provisioners.each do |provisioner|
          ui.logger.info { ">>>>> #{object.id.to_s.upcase} #{klass.upcase} #{action.to_s.upcase} [#{method_name}] (#{provisioner}) <<<<<" }
          p = provisioner.new(object.config, ui)
          p.respond_to?(method_name) and p.send(method_name, object)
        end
      end

      def sudo
        %(sudo -p '#{sudo_prompt}')
      end

      def sudo_prompt
        %(sudo password for %u@%h: )
      end

    end

  end
end
