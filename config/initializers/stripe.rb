# set the Stripe keys in the file config/secrets.yml
# Stripe.api_key = Rails.application.secrets.stripe_api_key
Stripe.api_key = ENV["stripe_api_key"]
