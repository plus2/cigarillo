require 'eg.helper'

require 'cigarillo'
require 'peace_love'

PeaceLove.connect(:database => 'ci_eg')
PeaceLove.connection.drop_database('ci_eg')

B = Cigarillo::Coordinator::Build
R = Cigarillo::Coordinator::Repo

eg 'pretty progress' do
  id = B.collection.insert :hello => 'dolly'
  B.add_progress id.to_s, {'msg' => "hel\e[31mlo"} 

  B.find(id)
end

eg 'result message' do
  rid = R.collection.insert(:owner => 'plustwo', :name => 'thing')
  bid = B.collection.insert(:ref => 'master', :repo_id => rid, :result => {:status => 'ok'})

  b = B.find(bid)
  Show(b.result_message)

  b.result.status = 'failed'
  Show(b.result_message)

  b.progress = [
    {'tag' => 'integration', 'status' => 'finished', 'duration' => 42.9}
  ]
  Show(b.result_message)

  Show(b.campfire_message(b.result_message))
end