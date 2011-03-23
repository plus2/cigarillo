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
          if build_id = payload.delete('build_id')
            Build.record_result(build_id,payload)

            build = Build.find(build_id)

            build.campfire_message( build.result_message )

            if repo_info = build.repo_info_message
              build.campfire_message( repo_info )
            end
          end
        else
          @igor.call(env)
        end
      end
    end
  end
end
