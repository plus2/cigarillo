require 'angry_hash'
require 'angry_shell'
require 'yaml'

module Cigarillo
  module Utils
    class Db < Struct.new(:config,:igorenv)
      def initialize(config,igorenv)
        super AngryHash[config], AngryHash[igorenv]
      end

      def prepare!
        database_yml
        dbs.each {|db| db.create }
      end

      def database_yml
        dbyml = dbs.inject({}) {|dby,db| dby[db.environment] = db.database_yml; dby}

        (config.path+'config/database.yml').open('w') {|f| f << dbyml.to_yaml}
      end

      def dbs
        config.environments.map do |environment,cfg|
          cfg.update(:name => config.name)

          case cfg.preferred_adapter
          when 'postgres','postgresql'
            Pg.new(environment,cfg,igorenv)
          when 'mysql'
            Mysql.new(environment,cfg,igorenv)
          when 'mysql2'
            Mysql2.new(environment,cfg,igorenv)
          when 'mongo','mongodb'
            Mongo.new(environment,cfg,igorenv)
          else
            raise "unknown preferred_adapter '#{cfg.preferred_adapter}'"
          end
        end
      end

      class Base < Struct.new(:environment,:cfg,:igorenv)
        include AngryShell::ShellMethods

        def database_yml
          {
            :adapter  => normalised_adapter_name,
            :database => database,
            :username => cfg.username || username,
            :password => cfg.password || password,
            :host     => 'localhost'
          }
        end

        def database
          "#{cfg.name}_#{environment}"
        end

        def create
        end

        def password; '' end
      end

      class Pg < Base
        def normalised_adapter_name; 'postgresql' end
        def username; 'plus2' end
        def create
          sh("createdb #{database}").run
        end
      end

      class Mongo < Base
        def normalised_adapter_name; 'mongodb' end
        def username; '' end
      end

      class Mysql < Base
        def normalised_adapter_name; 'mysql' end
        def username; 'root' end

        def creator_username 
          begin
            igorenv['cigarillo.mysql'].creator_username
          rescue
            'root'
          end
        end
        def creator_password
          begin
            igorenv['cigarillo.mysql'].creator_password
          rescue
            nil
          end
        end

        def create
          if creator_password.nil?
            sh("mysqladmin -u#{creator_username} create #{database}").run
          else
            sh("mysqladmin -u#{creator_username} -p#{creator_password} create #{database}").run
          end
        rescue AngryShell::ShellError
          if $!.result.stderr[/database exists/]
            puts "database exists, but that's ok with me"
          else
            raise $!
          end
        end
      end

      class Mysql2 < Base
        def normalised_adapter_name; 'mysql2' end
      end
    end
  end
end
