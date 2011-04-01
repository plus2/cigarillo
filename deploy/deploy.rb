require 'yaml'
require 'pathname'

act :on => 'yesmaster/prepare_app' do
  path = Pathname(node.current_path)

  if db = node.databases.find {|d| d.env == node.rack_env}
    node.cigarillo.coordinator.mongo = {
      'host' => db.host,
      'username' => db.username,
      'password' => db.password,
      'database' => db.id
    }
  end

  file path+'config.yml', :string => node.cigarillo.worker.to_yaml
  file path+'coord.yml' , :string => node.cigarillo.coordinator.to_yaml


  if node.name == 'ci'
    cleaner = path+'bin/clean_checkouts'
    etc_crontab "ci-checkout-cleaner", :crontab => "25 * * * * #{cleaner}"
  end
end
