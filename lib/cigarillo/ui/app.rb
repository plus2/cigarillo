require 'sinatra'

module Cigarillo
  module Ui
    class App < Sinatra::Base
      set :root, Cigarillo.root+'ui'
      
      enable :logging, :dump_errors

      get '/' do
        @css = %W{index}
        @repos = Cigarillo::Coordinator::Repo.all
        haml :index
      end

      get '/repos/:id' do |id|
        @css = %W{repo}
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

      get '/repos/:id/force-build/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @build = @repo.force_build!(ref)
        redirect "/builds/#{@build._id}"
      end

      get '/builds/:id' do |id|
        @css = %W{build}
        @build = Cigarillo::Coordinator::Build.find(id)
        haml :build
      end
    end
  end
end
