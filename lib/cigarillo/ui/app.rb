require 'sinatra'

module Cigarillo
  module Ui
    class App < Sinatra::Base
      set :root, Cigarillo.root+'ui'
      
      enable :logging, :dump_errors

      before do
        @repos_menu = Cigarillo::Coordinator::Repo.all_by_last_seen_at(5).to_a
        @more_menu_repos = Cigarillo::Coordinator::Repo.count > @repos_menu.size

        @submenu_active = {}
      end
      helpers do
        def active(key)
          if @submenu_active && @submenu_active == key
            {:class => 'active'}
          else
            {}
          end
        end
      end

      def remove_current_repo_from_menu
        @repos_menu.delete_if {|repo| repo._id == @repo._id}
      end

      get '/' do
        @css = %W{index}
        @repos = Cigarillo::Coordinator::Repo.all
        haml :index
      end

      get '/repos/:id' do |id|
        @css = %W{repo}
        @repo = Cigarillo::Coordinator::Repo.find(id)

        remove_current_repo_from_menu

        if params[:setup]
          @submenu_active = 'setup'
          haml :repo_setup
        else
          @submenu_active = 'builds'
          haml :repo
        end
      end

      get '/builds/:id' do |id|
        @css = %W{build}
        @build = Cigarillo::Coordinator::Build.find(id)

        @repo  = @build.repo
        remove_current_repo_from_menu
        @submenu_active = 'builds'

        haml :build
      end

      # no view
      get '/repos/:id/ci/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.add_ref_to_ci(ref)
        redirect "/repos/#{@repo._id}"
      end

      # no view
      get '/repos/:id/no-ci/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.del_ref_from_ci(ref)
        redirect "/repos/#{@repo._id}"
      end

      #no view
      get '/repos/:id/force-build/:ref' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @build = @repo.force_build!(ref)
        redirect "/builds/#{@build._id}"
      end

    end
  end
end
