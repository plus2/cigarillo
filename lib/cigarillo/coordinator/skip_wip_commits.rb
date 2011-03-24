module Cigarillo
  module Coordinator
    class SkipWipCommits
      def initialize(igor)
        @igor = igor
      end

      def call(env)
        if Repo.wip_commit?(env['igor.payload'])
          puts "skipping [WIP] commit"
          puts "message: #{Repo.extract_commit_message(env['igor.payload'])}"
          env['igor.payload'].tapp
        else
          @igor.call(env)
        end
      end
    end
  end
end
