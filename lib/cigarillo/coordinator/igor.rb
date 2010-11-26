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
            build_id = Build.start_build(repo)

            # this triggers CI on workers
            {:build_id => build_id.to_s, :name => repo.full_name, :repo => {:url => repo.private_repo_url, :ref => repo.current_ref, :sha => repo.after}}
          end
        end
      end
    end
  end
end
