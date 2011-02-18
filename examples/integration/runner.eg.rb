require 'eg.helper'
require 'tmpdir'
require 'pathname'
require 'cigarillo'

class MockProgress
  def info(tag, msg)
    msg.tapp(tag)
  end
end

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

puts "its a pty" if $stdout.tty?

100.times {|i|
	$stdout.puts "out #{i}"
	$stderr.puts "err #{i}"
}
	EOS
	
	env = AngryHash['progress' => MockProgress.new]

	env.ci!.environments!.test!.build_command = "ruby #{script_file}"
	env.repo!.checkout = "/tmp"

	Cigarillo::Integration::Runner.new.call(env)
end


eg 'runs structured' do
	script_file = script <<-'EOS'
#!/usr/bin/env ruby

puts "its a pty" if $stdout.tty?

100.times {|i|
	$stdout.puts '{"out":"'+i.to_s+'"}'
	$stderr.puts "err #{i}"
}

$stdout.flush

$stdout.puts 'xx foo'
$stdout.puts '{"xx":'+"\n"+' "foo"}'


$stdout.flush

100.times {|i|
	$stdout.puts '{"out":"'+(i+100).to_s+'"}'
	$stderr.puts "err #{i}"
}
	EOS
	
	env = AngryHash['progress' => MockProgress.new]

	env.ci!.environments!.test = {
    :build_command => "ruby #{script_file}",
    :progress      => 'structured'
  }
	env.repo!.checkout = "/tmp"

  puts "calling"
	Cigarillo::Integration::Runner.new.call(env)
end
