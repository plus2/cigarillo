require 'bunny'

module Cigarillo
	module Integration
		class ProgressLog
			def initialize(igor)
				@igor = igor
			end

			def call(env)
        env['cigarillo.build_id'] = build_id = env['igor.payload']['build_id']
        @progress_exchange ||= begin
															cfg = env['cigarillo-progress']
															b = Bunny.new(cfg['amqp'])
															b.start
															b.exchange(*cfg['exchange'])
														end
        env['progress'] = progress ||= Cigarillo::Utils::Progress.new(env['igor.errors'],@progress_exchange,build_id)

				@igor.call(env)
			end
		end
	end
end
