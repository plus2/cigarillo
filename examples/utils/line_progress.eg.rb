require 'eg.helper'
require 'cigarillo'

class FakeProgress < Struct.new(:out)
	def info(tag,data)
		out << [tag,data]
	end
end

eg 'buffer processing' do
	fp = FakeProgress.new(out = [])
	lp = Cigarillo::Utils::LineProgress.new(fp)

	z = lambda {|t| t.map {|s| ['out',s]}}
	lp.add('out', "Hello\nThere\nChamp\n")
	Assert( fp.out == z[%w{Hello There Champ}] )

	fp.out = []
	lp.add('out', "Hello\nThere\nChamp\nYeah")
	Assert( fp.out == z[%w{Hello There Champ}] )

	lp.add('out', " what's happening?\n")
	Assert( fp.out == z[%w{Hello There Champ} + ["Yeah what's happening?"]] )

	fp.out = []
	lp.add('out', "Hello\nThere\nChamp\nYeah")
	lp.finish

	Assert( fp.out == z[%w{Hello There Champ Yeah}] )
end
