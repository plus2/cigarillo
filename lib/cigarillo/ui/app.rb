require 'sinatra'

module Cigarillo
  module Ui
    class App < Sinatra::Base
      set :root, Cigarillo.root+'ui'

      get '/' do
        @repos = Cigarillo::Coordinator::Repo.all
        haml :index
      end

      get '/repos/:id' do |id|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        haml :repo
      end

      get '/repos/:id/ci/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.add_ref_to_ci(ref)
        redirect "/repos/#{@repo._id}"
      end

      get '/repos/:id/no-ci/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.del_ref_from_ci(ref)
        redirect "/repos/#{@repo._id}"
      end

      get '/repos/:id/force-build' do |id|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        redirect '/'
      end

      get '/builds/:id' do |id|
        @build = Cigarillo::Coordinator::Build.find(id)
        haml :build
      end
    end
  end
end
