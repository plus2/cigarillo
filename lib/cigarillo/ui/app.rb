require 'sinatra'

module Cigarillo
  module Ui
    class App < Sinatra::Base
      set :root, Cigarillo.root+'ui'
      
      enable :logging, :dump_errors

      before do
        @repos_menu = Cigarillo::Coordinator::Repo.all_by_last_seen_at(10).to_a
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

        def ansi_esc(string)
          Cigarillo::Utils::ANSI.new(string).to_html
        end

        def render_result(result)
          result = result.dup.extend(Cigarillo::Coordinator::ExampleResult)

          haml :_result, :locals => {:result => result}
        end

        def status_icon(kind)
          icon = case kind.to_s
          when 'error'
            '☠'
          when 'failure'
            '✕'
          when 'success'
            '✓'
          when /info/
            '☞'
          else
            kind.to_s
          end

          "<span class='#{kind}'>#{icon}</span>"
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
          @reflog = @repo.reflog
          haml :repo_setup
        else
          @submenu_active = 'builds'
          @builds = @repo.builds(:fields => %w{repo_id created_at ref result})
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

      def redir_setup(repo)
        redirect "/repos/#{repo._id}?setup=1"
      end

      # no view
      get '/repos/:id/ci/*' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.add_ref_to_ci(ref)
        redir_setup(@repo)
      end

      # no view
      get '/repos/:id/no-ci/*' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.del_ref_from_ci(ref)
        redir_setup(@repo)
      end

      # no view
      get '/repos/:id/ci-all' do |id|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.set_ci_all!
        redir_setup(@repo)
      end

      # no view
      get '/repos/:id/ci-selected' do |id|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @repo.set_ci_selected!
        redir_setup(@repo)
      end

      #no view
      get '/repos/:id/force-build/*' do |id,ref|
        @repo = Cigarillo::Coordinator::Repo.find(id)
        @build = @repo.force_build!(ref)
        redirect "/builds/#{@build._id}"
      end

    end
  end
end
