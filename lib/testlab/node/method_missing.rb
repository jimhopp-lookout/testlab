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

    module MethodMissing

      # Node Method Missing Handler
      def method_missing(method_name, *method_args)
        @ui.logger.debug { "NODE METHOD MISSING: #{method_name.inspect}(#{method_args.inspect})" }

        if TestLab::Provider::PROXY_METHODS.include?(method_name)
          result = nil

          if @provider.respond_to?(method_name)
            @ui.logger.debug { "@provider.send(#{method_name.inspect}, #{method_args.inspect})" }
            result = @provider.send(method_name, *method_args)
          else
            raise TestLab::ProviderError, "Your provider does not respond to the method '#{method_name}'!"
          end

          result
        else
          super(method_name, *method_args)
        end
      end

    end

  end
end
