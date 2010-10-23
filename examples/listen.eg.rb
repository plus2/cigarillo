require 'eg.helper'
require 'amqp'
require 'mq'
require 'yajl'

AMQP.start do
  MQ.queue('yoohoo-response').subscribe do |header,msg|
    puts "recv response"
    # header.tapp(:header)
    begin
      Yajl::Parser.parse(msg).tapp(:msg)
    rescue
      msg.tapp(:msg)
    end
    puts
  end

  MQ.queue('yoohoo-progress').subscribe do |header,msg|
    puts "recv progress"
    # header.tapp(:header)
    begin
      Yajl::Parser.parse(msg).tapp(:msg)
    rescue
      msg.tapp(:msg)
    end
    puts
  end
end
