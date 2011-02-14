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

          cmd = {
            :cmd => "script -q ci.output -c 'bundle exec #{options['build_command']}'",
            :cwd => env['runner.cwd'],
            :stream => true,
            :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}
          }

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

          {:env => environment, :success => result.ok?}
        end

        # send this message back on the response_exchange
        Cigarillo::Utils::Result.new(env).finish! do |res|
          res.details[:builds] = builds
          res.status builds.all? {|res| res[:success]} ? 'ok' : 'fail'
        end
      end

    end
  end
end
