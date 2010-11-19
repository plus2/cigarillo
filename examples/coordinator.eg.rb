require 'rubygems'
require 'bunny'
require 'yajl'

payload = <<-EOE
{
  "after": "fd8e90fc0fac89b8d573cf4b3f6d1a962c4901bf",
  "compare": "https:\/\/github.com\/plustwo\/compliance-hound\/compare\/1ea931a...f189155", 
  "forced": false, 
  "ref": "refs\/heads\/production", 
  "repository": {
    "created_at": "2010\/07\/25 16:20:22 -0700", 
    "description": "", 
    "fork": false, 
    "forks": 0, 
    "has_downloads": true, 
    "has_issues": true, 
    "has_wiki": true, 
    "homepage": "", 
    "name": "compliance-hound", 
    "open_issues": 0, 
    "organization": "plustwo", 
    "owner": {
      "email": "ben@plus2.com.au", 
      "name": "plustwo"
    }, 
    "private": true, 
    "pushed_at": "2010\/11\/15 16:38:40 -0800", 
    "url": "https:\/\/github.com\/plustwo\/compliance-hound", 
    "watchers": 1
  }
}

EOE

Bunny.run(:logging => true) do |b|
  # start a communication session with the amqp server

  # declare a queue
  q = b.queue('cigarillo-coord')

  # publish a message to the queue
  q.publish(payload)
end

