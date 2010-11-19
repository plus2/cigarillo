module Cigarillo
  module Coordinator
    module Repo
      include PeaceLove::Doc
      mongo_collection 'repos'

      def self.all
        collection.find()
      end

      def self.find(id)
        collection.find(:_id => BSON::ObjectId(id)).first
      end

      def builds
        Build.for_repo(self)
      end

      def self.record_repo(repo)
        name  = repo['name']
        owner = repo['owner']['name']
        ref = plain_ref(repo['ref'])

        repo = collection.find_one(:name => name, :owner => owner)
        
        if repo
          repo['refs'].tap {|r|
            r << ref
            r.uniq!
          }
          collection.update({:name => name, :owner => owner}, :$addToSet => {:refs => ref})
        else
          collection.insert(
            :name  => name,
            :owner => owner,
            :refs  => [ref],
            :ci    => {}
          )
          repo = collection.find_one(:name => name, :owner => owner)
        end

        repo.current_ref = ref
        repo
      end

      def self.plain_ref(ref)
        ref.sub(%r{^refs/heads/},'')
      end

      def ci?(ref=nil)
        ci[ ref || current_ref ]
      end

      def full_name
        "#{owner}-#{name}"
      end

      def private_repo_url
        "git@github.com:/#{owner}/#{name}.git"
      end
    end
  end
end
