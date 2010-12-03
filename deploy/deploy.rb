require 'yaml'
require 'pathname'

act :on => 'yesmaster/prepare_app' do
  path = Pathname(node.current_path)

  db = node.databases.find {|d| d.env == node.rack_env}

  node.cigarillo.coordinator.mongo = db

  file path+'config.yml', :string => node.cigarillo.worker.to_yaml
  file path+'coord.yml' , :string => node.cigarillo.coordinator.to_yaml
end
