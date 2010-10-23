require 'angry_hash'
require 'yaml'

module Cigarillo
  module Utils
    class Db < Struct.new(:config)
      def initialize(config)
        super AngryHash[config]
      end

      def prepare!
        database_yml
        dbs.each {|db| db.create }
      end

      def database_yml
        dbyml = dbs.inject({}) {|dby,db| dby[db.env] = db.database_yml; dby}

        (config.path+'config/database.yml').open('w') {|f| f << dbyml.to_yaml}
      end

      def dbs
        config.environments.map do |env,cfg|
          cfg.update(:name => config.name)

          case cfg.preferred_adapter
          when 'postgres','postgresql'
            Pg.new(env,cfg)
          when 'mysql'
            Mysql.new(env,cfg)
          when 'mongo','mongodb'
            Mongo.new(env,cfg)
          end
        end
      end

      class Base < Struct.new(:env,:cfg)
        def database_yml
          {
            :adapter => normalised_adapter_name,
            :database => database,
            :username => cfg.username || username,
            :password => cfg.password || password,
            :host => 'localhost'
          }
        end

        def database
          "#{cfg.name}_#{env}"
        end

        def create
        end

        def password; '' end
      end

      class Pg < Base
        def normalised_adapter_name; 'postgresql' end
        def username; 'plus2' end
      end

      class Mongo < Base
        def normalised_adapter_name; 'mongodb' end
        def username; '' end
      end

      class Mysql < Base
        def normalised_adapter_name; 'mysql' end
        def username; 'root' end
      end
    end
  end
end
