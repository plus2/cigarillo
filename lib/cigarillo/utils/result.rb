module Cigarillo
  module Utils
    class Result
      def initialize(env,&blk)
        @env = env
        @result = {}

      end

      def status(status)
        @result[:status] = status
      end
      def message(msg)
        @result[:message] = msg
      end

      def details
        @result[:details] ||= {}
      end

      def finish!(&blk)
        if block_given?
          yield self
        end
        @result.merge( 'cigarillo-kind' => 'result', :build_id => @env['cigarillo.build_id'] )
      end
    end
  end
end
