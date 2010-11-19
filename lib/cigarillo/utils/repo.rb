require 'angry_hash'
require 'angry_shell'

module Cigarillo
  module Utils
    class Repo
      include AngryShell::ShellMethods
      attr_reader :config

      def initialize(config)
        @config = AngryHash[ config ]

        # XXX verify name, url and ref
      end

      def name
        config.name
      end

      def sync!
        if repo.exist?
          git("fetch").run
        else
          git("clone #{config.repo.url} #{repo}", :cwd => repos).run
        end
      end

      def checkout!
        git("clone -s -n #{repo} #{checkout}").run
        git("reset --hard #{ref_sha}", :cwd => checkout).run
      end

      def submodules!
        git("submodule update --init", :cwd => checkout).run
      end

      # refs
      def ref_sha
        @ref_sha ||= begin
                       git("rev-parse #{remote_ref}").to_s.tap {|sha|
                         raise("sha not found for ref #{remote_ref}") if sha == ''
                       }
                     end
      end

      def remote_ref
        @remote_ref ||= "origin/#{config.repo.ref}"
      end

      def ref
        @ref ||= config.repo.ref
      end

      ## paths

      ### checkouts
      def checkout
        @checkout ||= checkouts + config.build_id
      end

      def in_checkout(&blk)
        Dir.chdir(checkout,&blk)
      end

      def checkouts
        @checkouts ||= (Cigarillo.workbench+'checkouts'+name).tap {|p| p.mkpath}
      end

      ### repos
      def repo
        @repo ||= begin
                    source = config.repo.url.gsub(/[^A-Za-z]+/,'-')
                    repos + "#{name}-#{source}"
                  end
      end

      def repos
        @repos ||= (Cigarillo.workbench+'repos').tap {|p| p.mkpath}
      end

      # git helper
      def git(*cmd)
        opts = Hash === cmd.last ? cmd.pop : {}

        sh("git #{cmd}".tapp, opts.merge(:cwd => (opts[:cwd] || repo)))
      end
    end
  end
end
