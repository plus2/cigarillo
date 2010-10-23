module Cigarillo
  module Integration
    class Runner
      include AngryShell::ShellMethods

      def call(env)
        progress = env['progress']

        result = AngryShell::Shell.new.popen4(:cmd => command, :cwd => repo.checkout, :stream => true) do |cid,ipc|
          puts ipc.stdout.read
        end
      end
    end
  end
end
