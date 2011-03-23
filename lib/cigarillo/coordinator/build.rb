require 'peace_love'

module Cigarillo
  module Coordinator
    module Build
      include PeaceLove::Doc
      mongo_collection 'builds'

      def self.start_build(repo, ref=nil)
        ref ||= repo.current_ref
        id = collection.insert :created_at => Time.now.strftime("%Y-%m-%d %H:%M:%S"), :repo_id => repo._id, :sha => repo.after, :ref => ref # XXX sha? current_ref? ref?
        collection.ensure_index([['repo_id', Mongo::ASCENDING]])
        collection.ensure_index([['created_at', Mongo::DESCENDING]])
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

      def self.for_repo(repo,options={})

        options[:sort] ||= [['created_at',:desc]]
        collection.find({:repo_id => repo._id}, options)
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

      def ci_message(ref_to_build=nil)
        ref_to_build ||= ref
        {:build_id => _id.to_s, :name => repo.full_name, :repo => {:url => repo.private_repo_url, :ref => ref_to_build}}
      end

      def campfire_message(msg,ref_to_build=nil)
        ref_to_build ||= ref
        # the exchange is a bit hard-coded for now
        {:exchange => 'plus2.messages', :app => 'cigarillo-coord', :msg => "[#{repo.path_name} #{ref}] #{msg} http://ci.plus2dev.com/builds/#{_id}"}
      end

      def result_message
        msg = "build #{succeeded? ? "succeeded" : "failed"}"

        if finished = integration_finished
          msg += " in #{finished['duration']}s"
        end

        msg
      end

      def repo_info_message
        if info = repo_info
          date = Time.at(info['date'].to_i)
          "[#{info['sha']}] #{info['msg']} - #{info['author']} on #{date}"
        end
      end

      def repo_info
        progress && progress.find {|p| p['tag'] == 'build-commit-info'}
      end

      def integration_finished
        progress && progress.find {|p| p['tag'] == 'integration' && p['status'] == 'finished'}
      end
        
      
    end
  end
end
