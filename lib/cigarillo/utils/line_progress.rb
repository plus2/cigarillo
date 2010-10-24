module Cigarillo
	module Utils
		class LineProgress
			def initialize(progress)
				@progress = progress
				@buffers = {}
			end

			def add(tag, data)
				(@buffers[tag] ||= '') << data
				process_buffers
			end

			def finish
				@buffers.each do |tag,buffer|
					@progress.info(tag,buffer) unless buffer.empty?
				end
			end

			def process_buffers
				@buffers.each do |tag,buffer|

					while n = buffer.index("\n")
						line = buffer[0..n-1]
						buffer = buffer[n+1..-1]

						@progress.info tag, line
					end

					@buffers[tag] = buffer
				end
			end
		end
	end
end
