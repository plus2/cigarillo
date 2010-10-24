require 'angry_shell'

module Cigarillo
  module Integration
    class GithubPing
			include AngryShell::ShellMethods

      def initialize(igor)
        @igor = igor
      end

      def call(env)
				dot_ssh    = Pathname("~/.ssh").expand_path
				id_dsa     = dot_ssh+'id_dsa'

				if !id_dsa.exist? && (github_token = env['cigarillo-github_api_token'])
					id_dsa_pub = dot_ssh+'id_dsa.pub'

					# Generate a key.
					sh( "echo | ssh-keygen -t dsa -f #{id_dsa}" ).run

					# Use the github API to register the key.
					sh( "curl -v -F 'login=plus2deployer' -F 'token=#{github_token}' -F 'key=#{id_dsa_pub.read.chomp}' " \
							"'https://github.com/api/v2/json/user/key/add' -H 'Accept: text/json'" ).run

					# ssh to github with `StrictHostKeyChecking no`. This stops us having to manually agreeing to add the key to our known_hosts.
					# This is probably a gaping security hole, mind.
					sh("ssh -o'StrictHostKeyChecking no' git@github.com; exit 0").run
				end

        @igor.call(env)
      end
    end
  end
end

