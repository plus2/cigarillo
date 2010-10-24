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
      :url => 'git@github.com:plustwo/compliance-hound.git',
      :url => '/Users/lachie/dev/plus2/compliance-hound',
      :ref => 'production',
    },
  }

  # publish a message to the queue
  q.publish(Yajl::Encoder.encode payload)
end
