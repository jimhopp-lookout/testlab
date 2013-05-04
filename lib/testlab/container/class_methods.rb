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

    module ClassMethods

      # Container domain list
      #
      # Returns an array of strings containing all the unique domains defined
      # across all containers
      #
      # @return [Array<String>] A unique array of all defined domain names.
      def domains
        self.all.map do |container|
          container.domain ||= container.node.labfile.config[:domain]
          container.domain
        end.compact.uniq
      end

    end

  end
end
