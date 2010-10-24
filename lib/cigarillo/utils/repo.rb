require 'angry_hash'
require 'angry_shell'

module Cigarillo
  module Utils
    class Repo
      include AngryShell::ShellMethods
      attr_reader :config

      def initialize(config)
        @config = AngryHash[ config ]
      end

      def name
        config.name
      end

      def sync!
        if repo.exist?
          # TODO XXX switch to non-bare repos
          git("fetch #{config.repo.url}").run
        else
          git("clone --bare #{config.repo.url} #{repo}", :cwd => repos).run
        end
      end

      def checkout!
        git("clone -s -b #{ref_sha} #{repo} #{checkout.tapp(:checkout)}", :cwd => checkouts).run
      end

      def submodules!
        git("submodule update --init", :cwd => checkout).run
      end

      # refs
      def ref_sha
        @ref_sha ||= begin
                       git("rev-parse #{ref}").to_s.tap {|sha|
                         raise("sha not found for ref #{ref}") if sha == ''
                       }
                     end
      end

      def ref
        @ref ||= config.repo.ref
      end


      ## paths

      ### checkouts
      def checkout
        @checkout ||= begin
                        index,latest = all_checkouts.last

                        index ||= -1

                        checkouts + "#{ref_sha}-#{index + 1}"
                      end
      end

      def in_checkout(&blk)
        Dir.chdir(checkout,&blk)
      end

      def all_checkouts
        Dir[checkouts + "#{ref_sha}-*"].map {|c| [c[/-(\d+)$/,1].to_i, c]}.sort_by {|c| c[0]}
      end

      def checkouts
        @checkouts ||= (Cigarillo.workbench+'checkouts'+name).tap {|p| p.mkpath}
      end

      ### repos
      def repo
        @repo ||= repos + "#{name}.git"
      end

      def repos
        @repos ||= (Cigarillo.workbench+'repos').tap {|p| p.mkpath}
      end

      # git helper
      def git(*cmd)
        opts = Hash === cmd.last ? cmd.pop : {}

        sh("git #{cmd}", opts.merge(:cwd => (opts[:cwd] || repo)))
      end
    end
  end
end
