require 'eg.helper'

require 'cigarillo'
require 'peace_love'

PeaceLove.connect(:database => 'ci_eg')
PeaceLove.connection.drop_database('ci_eg')

R = Cigarillo::Coordinator::Repo
B = Cigarillo::Coordinator::Build

eg.helpers do
  def record_repo(extras={})
    repo = AngryHash['name' => 'foobar', 'owner' => {'name' => 'foocorp'}, 'ref' => "refs/heads/master"].deep_merge(extras)
    R.record_repo(repo)
  end
end


eg 'creates a repo' do
  record_repo()
  R.all.first
end


eg 'adds a ref to ci' do
  r = record_repo()
  r.add_ref_to_ci('master')
  R.all.first
end


eg 'deletes a ref from ci' do
  r = record_repo(:ci => {'master' => true})
  Show(R.all.first)["before"]

  r.del_ref_from_ci('master')
  Show(R.all.first)["after"]
end


eg 'wip commit' do
	Show( R.wip_commit?( {} ) )
	Show( R.wip_commit?(nil) )
	Show( R.wip_commit?( {'after' => 'id', 'commits' => nil} ) )

	commit_id = '0xdeadbeef'
	payload = AngryHash[
		'repository' => { 'name' => 'foobar', 'owner' => {'name' => 'foocorp'}, 'ref' => "refs/heads/master" },
		'after' => commit_id,
		'commits' => [
		]
	]

	show_wip_commit = lambda {|commit|
		this_payload = payload.dup
		this_payload['commits'] = [ {'message' => commit, 'id' => commit_id} ]

		Show( R.wip_commit?(this_payload) )[commit]
	}
		
	show_wip_commit[ '[WIP] blah' ]
	show_wip_commit[ '[Wip] blah' ]
	show_wip_commit[ '[wip] blah' ]
	show_wip_commit[ 'yep yep [wip] blah' ]

	show_wip_commit[ 'yep yep wip blah' ]
	show_wip_commit[ '[wippet] blah' ]
end


eg 'summary' do
  repo_id = R.collection.insert(:owner => 'plustwo', :name => 'thing')

	add_build = lambda {|ref, status, created_at, summary|
		B.collection.insert(:repo_id => repo_id, :ref => ref, :result => {:status => status}, :created_at => created_at, :summary => summary)
	}

	base_time = Time.now.to_i

	add_build['master', 'failed', base_time, {
		"duration" => 0.83,
		"commit_message" => "Yup Yup",
		"sha" => "0xdeadbeef",
		"author" => "Bob Jones"
	}]

	add_build['master', 'ok', base_time, {
		"duration" => 0.83,
		"commit_message" => "Yup Yup",
		"sha" => "0xdeadbeef",
		"author" => "Job Bones"
	}]

	add_build['knuckles', 'failed', base_time+5, {
		"duration" => 0.83,
		"commit_message" => "Yup Yup",
		"sha" => "0xdeadbeef",
		"author" => "Bob Jones"
	}]

	# old commit
	add_build['knuckles', 'ok', base_time-(8 * 24*3600), {
		"duration" => 0.83,
		"commit_message" => "Yup Yup knuckles old",
		"sha" => "0xdeadbeef",
		"author" => "Bob Jones",
	}]

	repo = R.find(repo_id)
	repo.update_summary!

	R.find(repo_id)
end
