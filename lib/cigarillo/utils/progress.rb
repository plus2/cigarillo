require 'yajl'

module Cigarillo
  module Utils
    class Progress
      def initialize(log,exchange,build_id)
        @log      = log
        @exchange = exchange
        @build_id = build_id
      end

      def task(tag,msg='',extra={},&blk)
        start_time = Time.now
        @log.puts "starting #{tag} #{msg}"

        publish( extra.update(:status => 'started', :tag => tag, :msg => msg) )

        if block_given?
          yield.tap {|response|
            duration = Time.now-start_time
            @log.puts "finished #{tag} #{msg} in #{duration}s"
            publish( extra.update(:status => 'finished', :tag => tag, :msg => msg, :duration => duration) )
          }
        end
      end

      def info(tag,msg)
         publish( :tag => tag, :msg => msg )
      end

      def publish(data)
        @exchange.publish( Yajl::Encoder.encode(data.merge('cigarillo-kind' => 'progress', :build_id => @build_id)) )
      end
    end
  end
end
