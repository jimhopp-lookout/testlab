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
  class Container

    module Interface

      # Container primary interface
      #
      # Returns the primary interface for the container.  If the container has
      # multiple interfaces, this is based on which ever interface is marked
      # with the primary flag.  If the container only has one interface, then
      # it is returned.
      #
      # @return [TestLab::Interface] The primary interface for the container.
      def primary_interface
        if self.interfaces.any?{ |i| i.primary == true }
          self.interfaces.find{ |i| i.primary == true }
        else
          self.interfaces.first
        end
      end

    end

  end
end
