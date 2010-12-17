# Cigarillo

A message queue based CI setup.

# Background

I wanted to take advantage of our existing setup:

* We have a message queue set up (rabbitmq) which we use for various things already.
* All our repos on github are set up to hit our service-webhook-to-amqp bridge 
  * Its a trivial rack app based on <https://github.com/raggi/github_post_receive_server>
  * You can make service hooks connect straight to AMQP now, but we don't expose our rabbitmq to the internet.
  * We use these push notifications for various other things, such as [mirroring our git repos][mirrorigor]
* We use campfire to get a sense of our code flow, such as github pushes.
  * We have a message-queue-to-campfire bridge called [Spokesman-Igor][spokesman].
  * Eventually, [Spokesman-Igor][spokesman] will support more than just campfire.

I wanted something that's really flexible.

On average, the cigarillo setup is more complicated than most CI servers. However, its more modular; each piece is simpler and more flexible.

[spokesman]: https://github.com/plus2/spokesman-igor
[mirrorigor]: https://github.com/plus2/github-mirror-igor

# Layout

![pieces of cigarillo](https://img.skitch.com/20101217-n1rhmeqct6g2x5spisq4te3h94.jpg)

# Components

## Coordinator

## Worker

## UI
