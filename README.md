A cache invalidation rails-api application that can talk to Amazon CloudFront, Akamai CCUAPI, Varnish, and is easy to extend to work with other cache services. If you have multiple applications using multiple caching strategies, this application can help extract the complexity of purging the caches.

It uses a yaml file to store the custom config (eg API keys), the cache strategy classes (eg Cache::Akamai, Cache::CloudFront, Cache::Varnish) to handle the differences between the cache strategies, and redis queues (via sidekiq) to handle the outbound purge requests.

The goal is to be able to post minimal info to the api and cachepig will know how to handle it.
A simple example:
```
curl -d url=http://www.something.com/index.html http://cachepigs-url
```
Then in the config file:
```
cloud_front_example_server_one:
  strategy: CloudFront
  access_key: '123'
  secret_key: 'SECRET'
  distribution_id: 'DIST_ID_1'
  timeout_seconds: 1200
  urls:
    - /something.com/
```
Cachepig will match the url param to the regex in the cloud_front_example_server_one config hash and create a purging job/s to be queued.

Environment / Setup
----------------------------------------------

The application is tested against 1.9.2p320, ruby-1.9.3-p392, and ruby-2.0.0-p0, and requires redis to be running in the background.

To get the app running, clone the repo, modify the config file (there's an .yml.example config file in there if you want to experiment), then bundle install and start the server and sidekiq:
```
bundle install
bundle exec rails s
bundle exec sidekiq -C config/sidekiq.yml -L log/sidekiq.log
```

Walkthrough / Smoke Test
----------------------------------------------

After getting the application running locally, use curl to send purge requests:
```
curl -d url=http://www.something.com/index.html http://localhost:3000/caches
```
If there is a matching config hash in the yml file, it should respond with json looking something like this:
```
{"http://www.something.com/index.html":["Added to Cache::CloudFront queue","Added to Cache::Varnish queue"]
```
This tells you that the url sent matched two of the config hashes, a job was created for each and added to the relevant queue.
The queues can be monitored through the '/sidekiq' path.

If the url param doesn't match any of the config hashes, the json response will say so and the url will be ignored.
eg request:
```
curl -d url=http://www.notintheconfig.com http://localhost:3000/caches
```
response
```
{"http://www.notintheconfig.com":"Could not find cache config for 'http://www.notintheconfig.com'"}
```
Note: it is handy to use s3cmd if you're making invalidation requests to cloudfront:

```
curl -d 'cache[cache_type]=CloudFront' http://localhost:3000/caches
s3cmd cfinvalinfo cf://DIST_ID | head -n 30
```


Testing
----------------------------------------------

To run the specs:
```
bundle install
bundle exec rake spec
```

Accessing the Site
----------------------------------------------

There is currently no auth on cachepig, and the '/sidekiq' route is mounted so to run it on a publicly accessible server, auth or access control via IP tables needs to be added.

Adding Support for Other Caching Strategies
----------------------------------------------

1. Add the class to the app/models/cache/ folder (& spec to the spec/models/cache/ folder).
2. Update the config/sidekiq.yml file to run a queue for the new strategy.
3. Define the 'purge' method on the new class to handle the outbound request. This method is called whenever a queued job is processed.

Configuration
----------------------------------------------

There are some examples and comments in config/caches.yml.example. The minimum that is needed in a config hash is the name of the config (used as the hash key, and can be anything), the strategy (so that it knows which class to create a cache object from), and the urls:
```
cache_strategy_name:
  strategy: varnish
  urls:
    - http://www.something.com/index.html
    - /something.com/.*.jpg/
```
Any other config that is needed in the purge method can be added to the hash, to keep it DRY config can be added to a 'default_config' class method in the cache class (cachepig will check for the presence of this method, and given a hash will merge those options into the config).
Urls starting and ending with '/' are converted to regular expressions when matching the url params. They don't necessarily need to be urls, as long as the url params sent to cachepig match it and the caching strategy class has the necessary info to send the purge request, a string like 'cloudfront_purge_1' would also work.

Multiple urls can be sent in the request to cachepig. They can be comma or space delimited, and both the 'url' and 'urls' parametres will be used, otherwise they behave as expected, so characters like '&' need to be in a quoted string so that they aren't interpreted as the beginning of a different param.

Examples of valid requests to cachepig:
```
curl -d url=http://www.something.com http://cachepigs-url
curl -d urls=http://www.something.com,http://www.another.com/index.html http://cachepigs-url
curl -d url='http://www.something.com' http://cachepigs-url
curl -d urls='http://www.something.com,http://www.another.com/index.html' http://cachepigs-url
curl -d urls='http://www.something.com http://www.another.com/index.html' http://cachepigs-url
curl -d url=something.com http://cachepigs-url
curl -d "url='http://www.something.com'&another_param=true" http://cachepigs-url
```

