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


      def builds(options={})
        options[:sort] ||= [[:created_at, :desc]]
        Build.for_repo(self, options)
      end


      def self.record_repo(repo)
        name  = repo['name']
        owner = repo['owner']['name']
        ref = plain_ref(repo['ref'])

        repo = collection.find_one(:name => name, :owner => owner)
        
        now = Time.now.to_i

        if repo
          repo['refs'].tap {|r|
            r << ref
            r.uniq!
          }

          collection.update({:name => name, :owner => owner},
                            :$addToSet => {:refs => ref},
                            :$push     => {:reflog => {:ref => ref, :at => now}},
                            :$set      => {:last_seen_at => now}
                           )
        else
          attrs = {
            :name  => name,
            :owner => owner,

            :last_seen_at => now,
            :refs  => [ref],
            :reflog => [ {:ref => ref, :at => now} ],

            :ci    => {}
          }

          attrs[:local_url] = repo['local_url'] if repo && repo['local_url']

          collection.insert(attrs)
          repo = collection.find_one(:name => name, :owner => owner)
        end

        repo.current_ref = ref
        repo
      end


			def add_build_id!(build_id)
        __collection.update({:_id => _id}, :$push => {:builds => oid(build_id)})
			end


			#############
			#  summary  #
			#############
			def update_summary!
				earliest = Time.now.to_i - (7 * 24 * 3600)

				leaderboard = Build.collection.group(
					:key => :ref, :cond => {:repo_id => _id, :created_at => {:$gte => earliest}},
					:initial => {},
					:reduce => 'function(doc, out) {
						if(!out.created_at || doc.created_at > out.created_at) {
							out.created_at = doc.created_at

							if(doc.result && doc.result.status)
								out.result     = doc.result.status
							
							var s;
							if(s = doc.summary) {
								out.duration       = s.duration
								out.commit_message = s.commit_message
								out.sha            = s.sha
								out.author         = s.author
							}
						}
					}'
				)

				__collection.update({:_id => _id}, :$set => {:summary => leaderboard.to_a})
			end


			############################
			#  commit message helpers  #
			############################

			def self.extract_commit_message(payload)
				if payload.present?
					id = payload['after']
					commit = payload['commits'].try(:find) {|c| c['id'] == id}

					commit['message'] if commit
				end
			end

			def self.wip_commit?(payload)
				msg = extract_commit_message(payload)
				!!( msg && msg[/\[wip\]/i] )
			end


			###############
			#  accessors  #
			###############

      def reflog
        (self['reflog'] || []).reverse
      end


      def self.plain_ref(ref)
        ref.sub(%r{^refs/heads/},'')
      end


      def ci?(ref=nil)
        ci_all || ci[ ref || current_ref ]
      end


      def full_name
        "#{owner}-#{name}"
      end


      def path_name
        "#{owner}/#{name}"
      end


      def private_repo_url
        local_url || "git@github.com:/#{owner}/#{name}.git"
      end


      def add_ref_to_ci(ref)
        __collection.update( {:_id=>_id}, :$set => {"ci.#{ref}" => true} )
      end


      def del_ref_from_ci(ref)
        __collection.update( {:_id=>_id}, :$unset => {"ci.#{ref}" => 1} )
      end


      def set_ci_all!
        __collection.update( {:_id=>_id}, :$set => {"ci_all" => 1} )
      end


      def set_ci_selected!
        __collection.update( {:_id=>_id}, :$unset => {"ci_all" => 1} )
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
