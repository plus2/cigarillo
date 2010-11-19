module Cigarillo
  module Coordinator
    class Igor
      def initialize
      end

      def call(env)
        env.tapp(:plist)
        payload = env['igor.payload']

        if Hash === payload
          handle_ci(payload['repository'],payload) if payload['repository']
        end
      end

      def handle_ci(repo,payload)
        repo.tap {|r|
          r['ref'] = payload['ref']
        }

        repo = Repo.record_repo(repo).tapp

        if repo.ci?
          puts "triggering ci"
          build_id = Build.start_build(repo)

          {:build_id => build_id.to_s, :name => repo.full_name, :repo => {:url => repo.private_repo_url, :ref => repo.current_ref, :sha => repo.after}}
        end
      end
    end
  end
end
