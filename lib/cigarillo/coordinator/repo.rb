require 'bunny'
require 'yajl'

module Cigarillo
  module Coordinator
    module Repo
      include PeaceLove::Doc
      mongo_collection 'repos'

      def self.to_oid(id)
        case id
        when BSON::ObjectId
          id
        else
          BSON::ObjectId(id.to_s)
        end
      end

      def self.all
        collection.find()
      end

      def self.all_by_last_seen_at(limit=nil)
        opts = {:limit => limit, :sort => [[:last_seen_at,:desc]]}
        collection.find({}, opts)
      end

      def self.find(id)
        collection.find(:_id => to_oid(id)).first
      end

      def self.count
        collection.count
      end

      def builds
        Build.for_repo(self, :sort => [[:created_at, :desc]])
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

      def path_name
        "#{owner}/#{name}"
      end

      def private_repo_url
        "git@github.com:/#{owner}/#{name}.git"
      end

      def add_ref_to_ci(ref)
        __collection.update( {:_id=>_id}, :$set => {"ci.#{ref}" => true} )
      end

      def del_ref_from_ci(ref)
        __collection.update( {:_id=>_id}, :$unset => {"ci.#{ref}" => 1} )
      end

      def force_build!(ref)
        exchange = $cigarillo_config.ui.build_exchange

        Build.start_build(self,ref).tap {|build|
          message = build.ci_message(ref)

          Bunny.run($cigarillo_config.amqp) do |b|
            b.exchange(exchange.name, :type => exchange.kind).publish(Yajl::Encoder.encode(message))
          end
        }
      end
    end
  end
end
