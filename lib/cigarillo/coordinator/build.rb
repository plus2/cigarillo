require 'peace_love'

module Cigarillo
  module Coordinator
    module Build
      include PeaceLove::Doc
      mongo_collection 'builds'

      def self.start_build(repo)
        id = collection.insert :created_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"), :repo_id => repo._id, :sha => repo.after # XXX sha? current_ref? ref?
        find(id)
      end

      def self.add_progress(build_id,progress)
        collection.update({:_id => BSON::ObjectId(build_id)}, :$push => {:progress => progress})
      end

      def self.record_result(build_id,result)
        collection.update({:_id => BSON::ObjectId(build_id)}, :$set => {:result => result})
      end

      def self.all
        collection.find()
      end

      def self.for_repo(repo)
        collection.find({:repo_id => repo._id}, :sort => [['created_at',Mongo::ASCENDING]])
      end

      def self.find(id)
        collection.find(:_id => Repo.to_oid(id)).first
      end

      def repo
        @repo ||= Cigarillo::Coordinator::Repo.find(repo_id)
      end

      def succeeded?
        result.status == 'ok'
      end

      def result
        self['result']
      end

      def ci_message(ref)
        {:build_id => _id.to_s, :name => repo.full_name, :repo => {:url => repo.private_repo_url, :ref => ref}}
      end
      
    end
  end
end
