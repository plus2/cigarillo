require 'yajl'

module Cigarillo
  module Utils
    class Progress
      def initialize(log,queue)
        @log = log
        @queue = queue
      end

      def task(tag,msg='',extra={},&blk)
        start_time = Time.now
        @log.puts "starting #{tag} #{msg}"
        @queue.publish( Yajl::Encoder.encode( extra.update(:status => 'started', :tag => tag, :msg => msg) ) )
        if block_given?
          yield.tap {|response|
            duration = Time.now-start_time
            @log.puts "finished #{tag} #{msg} in #{duration}s"
            @queue.publish( Yajl::Encoder.encode( extra.update(:status => 'finished', :tag => tag, :msg => msg, :duration => duration) ) )
          }
        end
      end
    end
  end
end
