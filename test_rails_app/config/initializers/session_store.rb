# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_test_rails_app_session',
  :secret      => '5860f6c959c01b4889db7a10fc5170c390a8d7c68d0410908a61b0c5e1521412ffbada2b4723246cc5a3a1eebf4899e70eda532c5e464c767b333bf14268506e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
