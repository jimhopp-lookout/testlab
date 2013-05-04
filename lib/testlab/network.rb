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

  # Network Error Class
  class NetworkError < TestLabError; end

  # Network Class
  #
  # @author Zachary Patten <zachary AT jovelabs DOT com>
  class Network < ZTK::DSL::Base
    STATUS_KEYS   = %w(node_id id state interface network netmask broadcast).map(&:to_sym)

    # Sub-Modules
    autoload :Actions,      'testlab/network/actions'
    autoload :Bind,         'testlab/network/bind'
    autoload :ClassMethods, 'testlab/network/class_methods'
    autoload :Lifecycle,    'testlab/network/lifecycle'
    autoload :Status,       'testlab/network/status'

    include TestLab::Network::Actions
    include TestLab::Network::Bind
    include TestLab::Network::Lifecycle
    include TestLab::Network::Status

    extend  TestLab::Network::ClassMethods

    include TestLab::Utility::Misc

    # Associations and Attributes
    belongs_to  :node,        :class_name => 'TestLab::Node'
    has_many    :interfaces,  :class_name => 'TestLab::Interface'

    attribute   :address
    attribute   :bridge

    attribute   :config


    def initialize(*args)
      super(*args)

      @ui     = TestLab.ui
    end

  end

end
