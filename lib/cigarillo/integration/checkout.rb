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

        begin
          env['repo']     = repo     ||= Cigarillo::Utils::Repo.new(env['igor.payload'])
        rescue
          return Cigarillo::Utils::Result.new(env).finish! do |res|
            res.status :error
            res.message $!.to_s
          end
        end

        progress = env['progress']


        progress.task :integration do
          progress.task :git do
            progress.task("git.sync") { repo.sync! }
            progress.task("git.checkout") { repo.checkout! }
            progress.task("git.submodules") { repo.submodules! }

            progress.info('build-commit-info', repo.info)

            progress.task("bundle") {
              sh("bundle install --path=#{Cigarillo.workbench+'bundle'} --without no_ci", :cwd => repo.checkout).run if (repo.checkout+'Gemfile').exist?
            }
          end

          env['runner.cwd'] = repo.checkout
          @igor.call(env)
        end
      end
    end
  end
end
