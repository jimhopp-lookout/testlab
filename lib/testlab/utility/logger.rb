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
        (max_key_length > 80) and (max_key_length = 80)
        (char * max_key_length)
      end

      def log_config(testlab)
        {
          "config_dir" => testlab.config_dir.inspect,
          "repo_dir" => testlab.repo_dir.inspect,
          "labfile_path" => testlab.labfile_path.inspect,
          "logdev" => testlab.ui.logger.logdev.inspect,
          "version" => TestLab::VERSION.inspect,
        }
      end

      def log_details(testlab)
        {
          "hostname" => "%s (%s)" % [Socket.gethostname.inspect, TestLab.hostname.inspect],
          "program" => $0.to_s.inspect,
          "argv" => ARGV.join(' ').inspect,
          "timezone" => Time.now.zone.inspect
        }
      end

      def log_ruby(testlab)
        dependencies = {
          "ruby_version" => RUBY_VERSION.inspect,
          "ruby_patchlevel" => RUBY_PATCHLEVEL.inspect,
          "ruby_platform" => RUBY_PLATFORM.inspect
        }

        defined?(RUBY_ENGINE)       and dependencies.merge!("ruby_engine" => RUBY_ENGINE)
        defined?(RUBY_DESCRIPTION)  and dependencies.merge!("ruby_description" => RUBY_DESCRIPTION)
        defined?(RUBY_RELEASE_DATE) and dependencies.merge!("ruby_release_date" => RUBY_RELEASE_DATE)

        dependencies
      end

      def log_gem_dependencies(testlab)
        {
          "gli_version" => ::GLI::VERSION.inspect,
          "lxc_version" => ::LXC::VERSION.inspect,
          "ztk_version" => ::ZTK::VERSION.inspect,
          "activesupport_version" => ::ActiveSupport::VERSION::STRING.inspect
        }
      end

      def log_external_dependencies(testlab)
        @command = ZTK::Command.new(:silence => true, :ignore_exit_status => true)

        {
          "vagrant_version" => @command.exec(%(/usr/bin/env vagrant --version)).output.strip.inspect,
          "virtualbox_version" => @command.exec(%(/usr/bin/env vboxmanage --version)).output.strip.inspect,
          "lxc_version" => @command.exec(%(/usr/bin/env lxc-version)).output.strip.inspect
        }
      end

      def log_header(testlab)
        log_lines = Array.new

        log_methods = [:log_details, :log_config, :log_ruby, :log_gem_dependencies, :log_external_dependencies]
        log_hashes = log_methods.collect{ |log_method| self.send(log_method, testlab) }

        max_key_length = log_hashes.collect{ |log_hash| log_hash.keys }.flatten.compact.map(&:length).max + 2
        max_value_length = log_hashes.collect{ |log_hash| log_hash.values }.flatten.compact.map(&:length).max + 2

        max_length = (max_key_length + max_value_length + 2)

        log_lines << log_page_break(max_length, '=')
        log_hashes.each do |log_hash|
          log_hash.sort.each do |key, value|
            log_lines << log_key_value(key, value, max_key_length)
          end
          log_lines << log_page_break(max_length, '=')
        end

        log_lines.flatten.compact
      end


    end

  end
end
