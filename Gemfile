#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

source 'https://rubygems.org'
ruby "2.1.1"

gem 'rails', '3.2.13'
gem 'rails-api'
gem 'sidekiq'
gem 'fog'
gem 'sidekiq-limit_fetch'
gem 'sidekiq-failures'
gem 'to_regexp'
gem 'rest-client'
gem 'akamai_api'
# for sidekick admin. protect if you enable this in production. see https://github.com/mperham/sidekiq/wiki/Monitoring
gem 'slim', ">= 1.3.0"
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'unicorn'
gem 'rails_12factor'

group :test, :development do
  gem 'pry'
  gem 'pry-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'debugger'
  gem 'simplecov'
  gem 'webmock'
end
