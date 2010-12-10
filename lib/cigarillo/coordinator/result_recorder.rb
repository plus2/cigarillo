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

            {:exchange => 'plus2.messages', :app => 'cigarillo-coord', :msg => "[#{build.repo.path_name}] build #{build.succeeded? ? "succeeded" : "failed"} http://ci.plus2dev.com/builds/#{build_id}"}
          end
        else
          @igor.call(env)
        end
      end
    end
  end
end
