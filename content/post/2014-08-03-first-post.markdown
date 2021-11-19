---
layout: post
title: "initial steps to use websocket-rails"
date: 2014-08-03 21:39:04 +0900
comments: true
tags: [rails, websocket]
---

This is the very initial steps to use websocket-rails.
Basically, I follow the lessons from [here](http://www.school.ctc-g.co.jp/columns/masuidrive/masuidrive14.html).
I also add some suplemental steps for smooth start and hopefully next steps to utilize this library.

### 1. prepare
```
$ ruby -v
ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-darwin11.0]

$ rails -v                                                                                                                                                   [~/Dropbox/rails]
Rails 4.1.4

$ gem -v
2.2.2

$ rails new websocket_rails_example && cd websocket_rails_example
...
...

$ gem install websocket-rails
Welcome to WebsocketRails v0.7.0!
Successfully installed websocket-rails-0.7.0
Parsing documentation for websocket-rails-0.7.0
Installing ri documentation for websocket-rails-0.7.0
Done installing documentation for websocket-rails after 1 seconds
1 gem installed

$ emacs Gemfile
# add below
gem 'websocket-rails'

$ rails g websocket_rails:install
      create  config/events.rb
      create  config/initializers/websocket_rails.rb
      append  app/assets/javascripts/application.js

```
### 2. modify controller
add controller inheriting WebsocketRails::BaseController.
here, define websocket method "message_receive" which accepts message from client event and broadcast it to client connected with "websocket_chat"
```
$ emacs app/controllers/websocket_chat_controller.rb
# -*- coding: utf-8 -*-                                                                                                                                                                         
class WebsocketChatController < WebsocketRails::BaseController
  def message_receive
    receive_message = message()
    broadcast_message(:websocket_chat, receive_message)
  end
end

```
### 3. routes
modify config/events.rb and map event "websocket_chat" to websocket method "message_receive"
```
add websocket_chat for events
$ emacs config/events.rb
WebsocketRails::EventMap.describe do
  subscribe :websocket_chat, to: WebsocketChatController, with_method: :message_receive
end
```
### 4. generate chat app
```
$ rails g controller chat index
      create  app/controllers/chat_controller.rb
       route  get 'chat/index'
      invoke  erb
      create    app/views/chat
      create    app/views/chat/index.html.erb
      invoke  test_unit
      create    test/controllers/chat_controller_test.rb
      invoke  helper
      create    app/helpers/chat_helper.rb
      invoke    test_unit
      create      test/helpers/chat_helper_test.rb
      invoke  assets
      invoke    coffee
      create      app/assets/javascripts/chat.js.coffee
      invoke    scss
      create      app/assets/stylesheets/chat.css.scss
```
### 5. define view
"trigger" sends data to event. "bind" subscribes message of the event specified on the first arg.
```
$ emacs app/view/chat/index.erb
<ul id="chat_area">

</ul>

<input id="comment" type="text">
<input id="send" type="button" value="send">

<script>

  var ws_rails = new WebSocketRails("localhost:3001/websocket");

  ws_rails.bind("websocket_chat", function(message){
    var message_li = document.createElement("li");
    message_li.textContent = message;
    document.getElementById("chat_area").appendChild(message_li);
  })
  document.getElementById("send").onclick =  function(){
　　var comment = document.getElementById("comment").value;
　　ws_rails.trigger("websocket_chat", comment);
　}

</script>

```


### 6. disable rack
if you use Websocket-Rails in development mode, you have to disable Rack::Lock.
```
$ emacs config/environments/development.rb
Rails.application.configure do
...
...
  # add below
  config.middleware.delete Rack::Lock
end
```
### 7. boot local websocket
boot websocket server locally and set rails to allow local websocket. here, we use redis for its backend.
```
$ emacs config/initializers/websocket_rails.rb
...
...
  # set standalone mode
  config.standalone = true
  config.redis_options = {:host => 'localhost', :port => '6379'}


install and boot redis
$ brew install redis

$ redis-server /usr/local/etc/redis.conf &
[28495] 07 Aug 00:09:05.582 * Max number of open files set to 10032
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 2.8.7 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 28495
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

[28495] 07 Aug 00:09:05.587 # Server started, Redis version 2.8.7
[28495] 07 Aug 00:09:05.588 * DB loaded from disk: 0.001 seconds
[28495] 07 Aug 00:09:05.588 * The server is now ready to accept connections on port 6379

boot websocket server
$ bundle exec rake websocket_rails:start_server
Websocket Rails Standalone Server listening on port 3001

```

### 8. boot rails
```
$ rails s
=> Booting Thin
=> Rails 4.1.4 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
=> Notice: server is listening on all interfaces (0.0.0.0). Consider using 127.0.0.1 (--binding option)
=> Ctrl-C to shutdown server
Thin web server (v1.6.2 codename Doc Brown)
Maximum connections set to 1024
Listening on 0.0.0.0:3000, CTRL+C to stop
```

### 9. access!
[enjoy!](http://localhost:3000/chat/index)

### 10. source
[here](https://github.com/tgib23/websocket_rails_example) is the repository of my sample.
