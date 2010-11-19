require 'rubygems'
require 'bundler'
Bundler.setup
require 'bunny'

@kidpids = kidpids = []
trap(:INT) do
  kidpids.each {|pid| Process.kill(:TERM,pid)}
  Process.waitall
end


def igor(*args)
  opts = Hash === args.last ? args.pop : {}

  args += opts.map {|k,v| "--#{k}=#{v}"}

  args = args.compact * ' '
  puts ">> igorup #{args}"
  @kidpids << fork {
    exec "bundle exec igorup igor #{args}"
  }
end

Bunny.run(:logging => true) do |b|
  coord  = b.queue('cigarillo-coord')
  builds = b.queue('cigarillo-builds')

  ex_progress = b.exchange('cigarillo-progress', :type => :fanout)
  ex_results  = b.exchange('cigarillo-results', :type => :fanout)
  ex_push     = b.exchange('plus2.git', :type => :topic)
  ex_builds   = b.exchange('cigarillo-builds', :type => :direct)
  
  puts "binding coordinator"

  coord.bind(ex_push, :key => 'push.#')
  coord.bind(ex_progress)
  coord.bind(ex_results)

  puts "binding builds"
  builds.bind(ex_builds)
end

puts "starting igors"

igor :config => 'config.yml'
#igor 'push_listener.iu', :config => 'push_listener.yml', :require => 'push_listener.rb'

Process.waitall
