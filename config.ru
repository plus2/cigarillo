$LOAD_PATH << ::File.expand_path('../lib', __FILE__)

require 'environment'
require 'cigarillo'

require 'peace_love'
PeaceLove.connect(:database => 'ci')


run Cigarillo::Ui::App.new
