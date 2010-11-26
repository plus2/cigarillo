module Cigarillo
  module Coordinator
    class ResultRecorder
      def initialize(igor)
        @igor = igor
      end

      def call(env)
        payload = env['igor.payload']
        if payload['cigarillo-kind'] == 'result'
          puts "recording result"
          build_id = payload.delete('build_id')
          Build.record_result(build_id,payload.tapp(:payload)) if build_id

          # XXX expand message!
          {:exchange => 'plus2.messages', :app => 'cigarillo-coord', :msg => 'build done'}
        else
          @igor.call(env)
        end
      end
    end
  end
end
