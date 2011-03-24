module Cigarillo
  module Coordinator
    class SkipWipCommits
      def initialize(igor)
        @igor = igor
      end

      def call(env)
        unless Repo.wip_commit?(env['igor.payload'])
          @igor.call(env)
        end
      end
    end
  end
end
