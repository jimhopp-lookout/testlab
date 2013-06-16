class TestLab
  module Utility

    # Logger Error Class
    class LoggerError < UtilityError; end

    # Logger Module
    #
    # @author Zachary Patten <zachary AT jovelabs DOT com>
    module Logger
      require 'socket'
      require 'active_support/version'

      def log_key_value(key, value, max_key_length)
        " %s%s: %s" % [ key.upcase, '.' * (max_key_length - key.length), value.to_s ]
      end

      def log_page_break(max_key_length, char='-')
        (char * max_key_length)
      end

      def log_details
        @command = ZTK::Command.new(:silence => true, :ignore_exit_status => true)
        {
          "hostname" => Socket.gethostname.inspect,
          "program" => $0.to_s.inspect,
          "vagrant_version" => @command.exec(%(/usr/bin/env vagrant --version)).output.strip.inspect,
          "virtualbox_version" => @command.exec(%(/usr/bin/env vboxmanage --version)).output.strip.inspect
        }
      end

      def log_ruby
        dependencies = {
          "ruby_version" => RUBY_VERSION.inspect,
          "ruby_patchlevel" => RUBY_PATCHLEVEL.inspect,
          "ruby_platform" => RUBY_PLATFORM.inspect
        }

        defined?(RUBY_ENGINE) and dependencies.merge!("ruby_engine" => RUBY_ENGINE)

        dependencies
      end

      def log_dependencies
        {
          "gli_version" => ::GLI::VERSION.inspect,
          "lxc_version" => ::LXC::VERSION.inspect,
          "ztk_version" => ::ZTK::VERSION.inspect,
          "activesupport_version" => ::ActiveSupport::VERSION::STRING.inspect,
        }
      end

      def log_header
        log_lines = Array.new

        details_hash       = log_details
        ruby_hash          = log_ruby
        dependencies_hash  = log_dependencies

        max_key_length = [details_hash.keys, ruby_hash.keys, dependencies_hash.keys].flatten.compact.map(&:length).max + 2
        max_value_length = [details_hash.values, ruby_hash.values, dependencies_hash.values].flatten.compact.map(&:length).max + 2

        max_length = (max_key_length + max_value_length + 2)

        log_lines << log_page_break(max_length, '=')
        details_hash.sort.each do |key, value|
          log_lines << log_key_value(key, value, max_key_length)
        end

        log_lines << log_page_break(max_length)
        ruby_hash.sort.each do |key, value|
          log_lines << log_key_value(key, value, max_key_length)
        end

        log_lines << log_page_break(max_length)
        dependencies_hash.sort.each do |key, value|
          log_lines << log_key_value(key, value, max_key_length)
        end

        log_lines << log_page_break(max_length, '=')

        log_lines.flatten.compact
      end


    end

  end
end
