module Cigarillo
  module Coordinator
    class Igor
      def initialize
      end

      def call(env)
        if repo = env['igor.payload']['repository']

          repo.tap {|r|
            r['ref'] = env['igor.payload']['ref']
          }

          repo = Repo.record_repo(repo).tapp

          # This push matches CI criteria. Assign a build_id and trigger the ci.
          if repo.ci?
            puts "triggering ci"
            build = Build.start_build(repo)

            # this triggers CI on workers
            build.ci_message(repo.current_ref)

          end
        end
      end
    end
  end
end
