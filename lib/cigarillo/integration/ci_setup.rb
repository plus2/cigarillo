module Cigarillo
  module Integration
    class CiSetup
      def initialize(igor)
        @igor = igor
      end

      def call(env)
        repo = env['repo']

        ci_yml = (repo.checkout+'config/ci.yml')
        unless ci_yml.exist?
          return Cigarillo::Utils::Result.new(env).finish! do |res|
            res.status :error
            res.message "config/ci.yml missing from #{repo.name}"
          end
        end

        env['ci'] = YAML.load(ci_yml.read).merge(:path => repo.checkout, :name => repo.name)

        progress = env['progress']
        
        begin
          progress.task("db.preparation") {
            Cigarillo::Utils::Db.new(env['ci'],env).prepare!
          }
        rescue
          return Cigarillo::Utils::Result.new(env).finish! do |res|
            res.status :error
            res.message "ci.yml was invalid (#{$!})"
          end
        end

        @igor.call(env)
      end
    end
  end
end
