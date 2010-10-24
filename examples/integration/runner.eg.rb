require 'eg.helper'
require 'tmpdir'
require 'pathname'
require 'cigarillo'

eg.helpers do
	def mk_runner(env)
		Cigarillo::Integration::Runner.new
	end

	def script(code)
		(Pathname(Dir.tmpdir) + 'cigarillo.runner.eg.script').tap {|script|
			script.open('w') {|f| f << code}
			script.chmod 0755
		}
	end
end

eg 'runs' do
	script_file = script <<-'EOS'
#!/usr/bin/env ruby

100.times {|i|
	$stdout.puts "out #{i}"
	$stderr.puts "err #{i}"
}
	EOS
	
	env = AngryHash.new

	env.ci!.environments!.test!.ci_command = "ruby #{script_file}"
	env.repo!.checkout = "/tmp"

	Cigarillo::Integration::Runner.new.call(env)
end
