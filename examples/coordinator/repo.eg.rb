require 'eg.helper'

require 'cigarillo'
require 'peace_love'

PeaceLove.connect(:database => 'ci_eg')
PeaceLove.connection.drop_database('ci_eg')

R = Cigarillo::Coordinator::Repo
eg.helpers do
  def repo(extras={})
    repo = AngryHash['name' => 'foobar', 'owner' => {'name' => 'foocorp'}, 'ref' => "refs/heads/master"].deep_merge(extras)
    R.record_repo(repo)
  end
end

eg 'creates a repo' do
  repo()
  R.all.first
end

eg 'adds a ref to ci' do
  r = repo()
  r.add_ref_to_ci('master')
  R.all.first
end

eg 'deletes a ref from ci' do
  r = repo(:ci => {'master' => true})
  Show(R.all.first)

  r.del_ref_from_ci('master')
  R.all.first
end
