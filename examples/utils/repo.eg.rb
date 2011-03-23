require 'eg.helper'
require 'cigarillo'

eg 'repo info' do
	config = AngryHash[:name => 'hereiam', :repo => {:url => 'http://url.com', :ref => 'master'}]

	r = Cigarillo::Utils::Repo.new(config)

	here = Pathname('../../..').expand_path(__FILE__)
	r.instance_eval { @checkout = here.to_s}

	r.checkout_info
end
