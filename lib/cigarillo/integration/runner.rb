require 'fcntl'
require 'angry_shell'

module Cigarillo
  module Integration
    class Runner
      def call(env)

        builds = env['ci']['environments'].map do |environment,options|
          unless options['build_command']
            next :env => environment, :result => nil
          end

          puts "running with #{options['progress']} progress"
          result = case options['progress']
                   when 'structured'
                     structured(env, environment, options)
                   when 'piped'
                     piped(env, environment, options)
                   when 'tty',nil
                     tty(env, environment, options)
                   end

          {:env => environment, :success => result.ok?}
        end

        # send this message back on the response_exchange
        Cigarillo::Utils::Result.new(env).finish! do |res|
          res.details[:builds] = builds
          res.status builds.all? {|res| res[:success]} ? 'ok' : 'fail'
        end
      end

      protected

      def tty(env, environment, options)
        progress = Cigarillo::Utils::LineProgress.new(env['progress'])

        # XXX script -c is linux only
        cmd = {
          :cmd => "script -q ci.output -c 'bundle exec #{options['build_command']}'",
          :cwd => env['runner.cwd'],
          :stream => true,
          :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}
        }

        run_with_progress(cmd, progress)
      end


      def piped(env, environment, options)
        progress = Cigarillo::Utils::LineProgress.new(env['progress'])

        cmd = {
          :cmd => "bundle exec #{options['build_command']}",
          :cwd => env['runner.cwd'],
          :stream => true,
          :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}
        }

        run_with_progress(cmd, progress)
      end


      def structured(env, environment, options)
        progress = Cigarillo::Utils::StructuredProgress.new(env['progress'])

        cmd = {
          :cmd => "bundle exec #{options['build_command']}",
          :cwd => env['runner.cwd'],
          :stream => true,
          :environment => {'RAILS_ENV' => environment, 'RACK_ENV' => environment}
        }

        run_with_progress(cmd, progress)
      end


      def run_with_progress(cmd, progress)
        AngryShell::Shell.new.popen4(cmd) do |cid,ipc|
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
      end

    end
  end
end
