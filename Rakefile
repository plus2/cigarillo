task :get_data do
  sh "ssh am-data2 /usr/local/mongodb/bin/mongodump -d plus2_ci"
  sh "rsync -avz am-data2:dump/ ./tmp/dump"
  sh "mongorestore ./tmp/dump"
end

task :coffee do
  sh "cd ui/scripts; coffee -wlc -o ../public/javascripts *.coffee"
end

task :sass do
  sh "sass --watch ui/views:ui/public/stylesheets"
end
