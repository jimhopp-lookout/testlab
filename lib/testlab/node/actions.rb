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
  class Node

    module Actions

      # Create the node
      def create
        @ui.logger.debug { "Node Create: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Create', :green)) do
          @provider.create
        end
      end

      # Destroy the node
      def destroy
        @ui.logger.debug { "Node Destroy: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Destroy', :red)) do
          @provider.destroy
        end
      end

      # Start the node
      def up
        @ui.logger.debug { "Node Up: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Up', :green)) do
          @provider.up
        end
      end

      # Stop the node
      def down
        @ui.logger.debug { "Node Down: #{self.id} " }

        please_wait(:ui => @ui, :message => format_object_action(self, 'Down', :red)) do
          @provider.down
        end
      end

    end

  end
end
