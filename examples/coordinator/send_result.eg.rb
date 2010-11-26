require 'eg.helper'
require 'bunny'
require 'yajl'
require 'cigarillo'
require 'peace_love'

PeaceLove.connect :database => 'ci_test'

eg 'send build results' do

  build_id = Cigarillo::Coordinator::Build.start_build( AngryHash[ :repo => {:_id => 'hello'}] ).tapp


  payload = {'cigarillo-kind' => 'result', :status => :ok, :build_id => build_id.to_s}

  Bunny.run(:logging => true) do |b|
    # start a communication session with the amqp server
    
    q_name = 'cigarillo-coord'

    # publish a message to the queue
    b.queue(q_name).publish(Yajl::Encoder.encode(payload))
  end

end
