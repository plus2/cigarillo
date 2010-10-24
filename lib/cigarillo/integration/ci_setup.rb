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
          return [500, {:msg => "config/ci.yml missing from #{repo.name}"}]
        end

        env['ci'] = YAML.load(ci_yml.read).merge(:path => repo.checkout, :name => repo.name)

        Cigarillo::Utils::Db.new(env['ci'],env).prepare!

        @igor.call(env)
      end
    end
  end
end
