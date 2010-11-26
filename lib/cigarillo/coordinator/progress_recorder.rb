module Cigarillo
  module Coordinator
    class ProgressRecorder
      def initialize(igor)
        @igor = igor
      end

      def call(env)
        payload = env['igor.payload']
        if payload['cigarillo-kind'] == 'progress'
          build_id = payload.delete('build_id')
          Build.add_progress(build_id, payload) if build_id
          nil
        else
          @igor.call(env)
        end
      end
    end
  end
end
