$LOAD_PATH << ::File.expand_path('../lib', __FILE__)

require 'environment'
require 'cigarillo'

require 'angry_hash'
require 'yaml'

require 'tapp'

$cigarillo_config = AngryHash[ YAML.load_file("coord.yml") ]

require 'peace_love'
PeaceLove.connect($cigarillo_config.mongo)


run Cigarillo::Ui::App.new
