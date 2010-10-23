require 'yajl'

module Cigarillo
  module Utils
    class Progress
      def initialize(queue)
        @queue = queue
      end

      def task(tag,msg='',extra={},&blk)
        start_time = Time.now
        @queue.publish( Yajl::Encoder.encode( extra.update(:status => 'started', :tag => tag, :msg => msg) ) )
        if block_given?
          yield.tap {|response|
            @queue.publish( Yajl::Encoder.encode( extra.update(:status => 'finished', :tag => tag, :msg => msg, :duration => Time.now-start_time) ) )
          }
        end
      end
    end
  end
end
