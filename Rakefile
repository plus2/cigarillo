task :get_data do
  sh "ssh am-data2 /usr/local/mongodb/bin/mongodump -d plus2_ci"
  sh "rsync -avz am-data2:dump/ ./tmp/dump"
  sh "mongorestore --drop ./tmp/dump"
end

task :coffee do
  sh "cd ui/scripts; coffee -wlc -o ../public/javascripts *.coffee"
end

task :sass do
  sh "sass --watch ui/views:ui/public/stylesheets"
end

task :db do
	$LOAD_PATH << File.expand_path("../lib",__FILE__)
	require 'environment'
	require 'tapp'
	require 'cigarillo'
	require 'peace_love'
	PeaceLove.connect(:database => 'plus2_ci')
end

task 'migrate-1' => :db do
	require 'time'

	b = Cigarillo::Coordinator::Build
	b.all.each do |build|
		created_at = Time.parse(build.created_at)
		b.collection.update({:_id => build._id}, :$set => {:created_at => created_at.to_i})
	end
end


task 'update_summaries' => :db do
	repo = Cigarillo::Coordinator::Repo.find('4d016d1d18764017ba000003')
	repo.builds.each {|build| build.summarise!}
	repo.update_summary!
end
