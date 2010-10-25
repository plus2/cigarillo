require 'fcntl'
require 'angry_shell'

module Cigarillo
  module Integration
    class Runner
      def call(env)
        progress = Cigarillo::Utils::LineProgress.new(env['progress'])
        repo = env['repo']

        env['ci']['environments'].each do |environment,options|
          next unless options['ci_command']

          # XXX repo.checkout should be more generic, perhaps... like 'runner.cwd'
          cmd = {:cmd => options['ci_command'], :cwd => repo.checkout, :stream => true, :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}}

          result = AngryShell::Shell.new.popen4(cmd) do |cid,ipc|
            readers = [ipc.stdout, ipc.stderr]

            until readers.empty?
              ready = IO.select(readers, nil, nil, 1.0)

              begin
                ready[0].each {|fd| 
                  tag = fd == ipc.stdout ? :out : :err
                  progress.add tag, fd.read_nonblock(512)
                }
              rescue EOFError
                readers.delete_if {|fd| fd.eof?}
              end
            end
          end

          [200, {:build => result.ok?}]
        end
      end

    end
  end
end
