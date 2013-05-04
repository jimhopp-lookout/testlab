################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
################################################################################
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
        mark = ((' ' * (60 - length)) + mark)

        ZTK::Benchmark.bench(:ui => ui, :message => message, :mark => mark) do
          yield
        end
      end

    end

  end
end
