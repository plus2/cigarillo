require 'bunny'

module Cigarillo
	module Integration
		class ProgressLog
			def initialize(igor)
				@igor = igor
			end

			def call(env)
        @progress_queue ||= begin
															cfg = env['cigarillo-progress']
															b = Bunny.new(cfg['amqp'])
															b.start
															b.queue(cfg['queue'])
														end
        env['progress'] = progress ||= Cigarillo::Utils::Progress.new(env['igor.errors'],@progress_queue)

				@igor.call(env)
			end
		end
	end
end
