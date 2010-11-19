require 'angry_shell'
require 'yajl'

module Cigarillo
  module Integration
    class Checkout
      include AngryShell::ShellMethods

      def initialize(igor)
        @igor = igor
      end

      def call(env)
        env['repo']     = repo     ||= Cigarillo::Utils::Repo.new(env['igor.payload'])
        progress = env['progress']


        progress.task :integration do
          progress.task :git do
            repo.sync!
            repo.checkout!
            repo.submodules!

            sh("bundle install --path=#{Cigarillo.workbench+'bundle'}", :cwd => repo.checkout).run if (repo.checkout+'Gemfile').exist?
          end

          env['runner.cwd'] = repo.checkout
          @igor.call(env)
        end
      end
    end
  end
end
