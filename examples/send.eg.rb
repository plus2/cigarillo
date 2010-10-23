require 'rubygems'
require 'bunny'
require 'yajl'

Bunny.run(:logging => true) do |b|
  # start a communication session with the amqp server

  # declare a queue
  q = b.queue('yoohoo')

  payload = {
    :name => 'compliance-hound',
    :repo => {
      :url => '/Users/lachie/dev/plus2/compliance-hound',
      :ref => '2271eaf1cc432d654a90320c71d1c8f4846b25dc',
      :ref => 'production',
    },
  }

  # publish a message to the queue
  q.publish(Yajl::Encoder.encode payload)
end
