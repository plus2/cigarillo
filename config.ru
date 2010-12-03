$LOAD_PATH << ::File.expand_path('../lib', __FILE__)

require 'environment'
require 'cigarillo'

require 'angry_hash'
require 'yaml'

config = AngryHash[ YAML.load_file("coord.yml") ]

require 'peace_love'
PeaceLove.connect(config.mongo)


run Cigarillo::Ui::App.new
