begin
  # Try to use the SystemTimer gem instead of Ruby's timeout library
  # when running on Ruby 1.8.x. See:
  #   http://ph7spot.com/articles/system_timer
  # We don't want to bother trying to load SystemTimer on jruby,
  # ruby 1.9+ and rbx.
  if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == 'ruby' && RUBY_VERSION < '1.9.0')
    require 'system_timer'
    TimeoutNazi = SystemTimer
  else
    require 'timeout'
    TimeoutNazi = Timeout
  end
rescue LoadError => e
  require 'timeout'
  TimeoutNazi = Timeout
end

module Cigarillo
  module Integration
    class TimeNazi
      def initialize(igor, timeout=20*60)
        @igor = igor
        @timeout = timeout
      end

      def call(env)
        begin
          TimeoutNazi.timeout(@timeout) do
            @igor.call(env)
          end
        rescue Object
          puts "[#{$!.class}] #{$!}"
          $!.backtrace.each {|line| puts "  #{line}"}

          Cigarillo::Utils::Result.new(env).finish! do |res|
            res.status :error
            res.message "a crashing error occurred: [#{$!.class}] #{$!}"
          end
        end
      end
    end
  end
end
