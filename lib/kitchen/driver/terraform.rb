# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen/config/cli"
require "kitchen/driver/terraform/verify_client_version"
require "terraform/configurable"

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < ::Kitchen::Driver::Base
      ::Kitchen::Config::CLI.call plugin_class: self

      include ::Terraform::Configurable

      kitchen_driver_api_version 2

      no_parallel_for

      def create(_state = nil); end

      def destroy(_state = nil)
        load_state do client.apply_destructively end
      rescue ::Kitchen::StandardError, ::SystemCallError => error
        raise ::Kitchen::ActionFailed, error.message
      end

      def verify_dependencies
        ::Kitchen::Driver::Terraform::VerifyClientVersion
          .call client: ::Terraform::Client.new(config: self, logger: debug_logger), logger: logger
      end

      private

      def load_state(&block)
        silent_client.load_state(&block)
      rescue ::Errno::ENOENT => error
        debug error.message
      end
    end
  end
end
