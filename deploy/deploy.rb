require 'yaml'
require 'pathname'

act :on => 'yesmaster/prepare_app' do
  file Pathname(node.current_path)+'config.yml', :string => node.cigarillo
end
