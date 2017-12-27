# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.4.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'dotenv-rails', groups: %i[development test]

gem 'flexirest'
gem 'jsonapi-rails'
gem 'okapi', git: 'git://github.com/thefrontside/okapi.rb/', branch: 'master'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.2'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'map', '~> 6.0'
  gem 'pry-byebug'
  gem 'pry-remote'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'vcr', '~> 3.0'
  gem 'webmock', '~> 3.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
