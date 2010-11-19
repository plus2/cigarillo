require 'fcntl'
require 'angry_shell'

module Cigarillo
  module Integration
    class Runner
      def call(env)
        progress = Cigarillo::Utils::LineProgress.new(env['progress'])

        builds = env['ci']['environments'].map do |environment,options|
          unless options['build_command']
            next :env => environment, :result => nil
          end

          # XXX repo.checkout should be more generic, perhaps... like 'runner.cwd'
          cmd = {:cmd => options['ci_command'], :cwd => repo.checkout, :stream => true, :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}}

          result = AngryShell::Shell.new.popen4(cmd) do |cid,ipc|
            readers = [ipc.stdout, ipc.stderr]

            until readers.empty?
              ready = IO.select(readers, nil, nil, 1.0) || next

              begin
                ready[0].each {|fd| 
                  tag = fd == ipc.stdout ? :out : :err
                  progress.add tag, fd.read_nonblock(512) #.taputs
                }
              rescue EOFError
                readers.delete_if {|fd| fd.eof?}
              end
            end
          end

          {:env => environment, :result => result.ok?}
        end

        [200, {:builds => builds, :build_id => env['cigarillo.build_id']}]
      end

    end
  end
end
