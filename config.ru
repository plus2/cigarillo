$LOAD_PATH << ::File.expand_path('../lib', __FILE__)

require 'environment'
require 'cigarillo'

require 'angry_hash'
require 'yaml'

require 'tapp'

$cigarillo_config = AngryHash[ YAML.load_file("coord.yml") ]

require 'peace_love'
PeaceLove.connect($cigarillo_config.mongo)


require 'pathname'

if ENV['RACK_ENV'] == 'production'
  log = Pathname('../cigarillo.ui.log').expand_path(__FILE__)
  puts "Note: now redirecting all output to #{log}"

  log.open('a').tap {|l|
    $stdout.reopen(l)
    $stderr.reopen(l)
  }
end



run Cigarillo::Ui::App.new
