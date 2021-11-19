---
layout: post
title: "deploy rails websocket app into heroku"
slug: deploy-rails-websocket-app-into-heroku
date: 2014-10-30 00:14:33 -0500
comments: true
tags: [heroku, rails, rails-websocket, websocket]
---

This post is to explain the configuration example to use heroku to deploy app with websocket-rails. The app is implemented in the [previous post](http://tgib23.github.io/blog/2014/08/03/first-post/) using standalone mode websocket server on local dev environment.

### 1. create heroku
Sign up for heroku and install heroku tool. Follow the [heroku setup instruction](https://www.railstutorial.org/book/beginning#sec-heroku_setup) in the rails tutorial.
```
$ heroku create
Creating gentle-tor-1752... done, stack is cedar
https://gentle-tor-1752.herokuapp.com/ | git@heroku.com:gentle-tor-1752.git
```

Now got gentle-tor-1752 for this entry.

### 2. redis setup
Because redis is used for the backend of websocket, we have to enable redis in heroku.
```
$ heroku addons:add redistogo                                                                                                            
Adding redistogo on gentle-tor-1752... done, v3 (free)
Use `heroku addons:docs redistogo` to view documentation.
```

Then, check the redis setting information from heroku web UI (app -> redistogo). You will find info on redis db, such as below.
```
redis://redistogo:xxxxxxxxxxxxxxxx@greeneye.redistogo.com:12345/
```

Next, apply these info on the redis setting.
```
$ vim config/initializers/websocket_rails.rb
...
-  config.redis_options = {:host => 'localhost', :port => '6379'}
+  config.redis_options = {:host => 'greeneye.redistogo.com', :port => '12345', :user => 'redistogo', :password => 'xxxxxxxxxxxxxxxx'}
...
```
If you don't like write password into code, maybe you can use environment variables.

### 3. change websocket url
Change the websocket url specified in the code. Again, there could be better way to do this, but I put it into code simply.
```
$ vim app/views/chat/index.html.erb
...
-  var ws_rails = new WebSocketRails("localhost:3001/websocket");
+  var ws_rails = new WebSocketRails("aqueous-springs-2658.herokuapp.com/websocket");

* change the hostname accoring to your setting.
...
```

### 4. small changes for heroku
put sqlite dev only and add pg and rails_12fator for prod env.
```
+group :development do
+  # Use sqlite3 as the database for Active Record
+  gem 'sqlite3'
+end
+
+group :production do
+  gem 'pg', '0.17.1'
+  gem 'rails_12factor', '0.0.2'
+end
```

commit Gemfile.lock
```
$ bundle install
$ git add Gemfile.lock
$ git commit -am 'add Gemfile.lock'
```

set root path
```
$ vim config/routes.rb
...
root to: "chat#index"
...
```

### 5. deploy and check
```
$ git push heroku master
$ heroku open
```
