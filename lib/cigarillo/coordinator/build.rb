require 'peace_love'

module Cigarillo
  module Coordinator
    module Build
      include PeaceLove::Doc
      mongo_collection 'builds'

      def self.start_build(repo)
        collection.insert :created_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"), :repo_id => repo._id, :sha => repo.after
      end

      def self.all
        collection.find()
      end

      def self.for_repo(repo)
        collection.find({:repo_id => repo._id}, :sort => [['created_at',Mongo::ASCENDING]])
      end

      def self.find(id)
        collection.find(:_id => BSON::ObjectId(id)).first
      end
    end
  end
end
