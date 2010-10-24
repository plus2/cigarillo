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
        @progress_queue ||= MQ.queue('yoohoo-progress')
        env['progress'] = progress ||= Cigarillo::Utils::Progress.new(@progress_queue)
        env['repo']     = repo     ||= Cigarillo::Utils::Repo.new(env['igor.payload'])

        progress.task :integration do
          progress.task :git do
            repo.sync!
            repo.checkout!
            repo.submodules!

            sh("bundle install --path=#{Cigarillo.workbench+'bundle'}", :cwd => repo.checkout).run if (repo.checkout+'Gemfile').exist?
          end

          @igor.call(env)
        end
      end
    end
  end
end
