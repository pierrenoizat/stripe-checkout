source 'https://rubygems.org'
ruby '2.2.0'
gem 'rails', '4.2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

# gem 'rqrcode' # to use pngqr
# gem 'chunky_png' # to use pngqr
# gem 'pngqr'

gem "ffi", "~> 1.2.0"
gem "bitcoin-addrgen",'~> 0.0.2' # this version uses the ffi gem for bindings to GMP library instead of the previous gmp gem
gem 'bitcoin-ruby', git: 'https://github.com/lian/bitcoin-ruby', branch: 'master', require: 'bitcoin'

gem 'figaro'
gem 'heroku_secrets', github: 'alexpeattie/heroku_secrets'
gem 'mechanize'
gem 'paymium_api', git: 'https://github.com/Paymium/paymium_api' # 0.0.7
gem 'oauth2', '~> 1.0.0'

gem 'recaptcha', require: 'recaptcha/rails'

gem 'aws-sdk', '~> 1.5.7'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
gem 'bootstrap-sass'
gem 'devise'
gem 'gibbon'
gem 'pg'
gem 'stripe'
gem 'sucker_punch'
group :development do
  gem 'better_errors'
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
end
group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end
