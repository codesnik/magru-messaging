# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_magru-messaging-scaffold_session',
  :secret => 'a8613af624e1dcdb3a6f532accc02a55b98ee9f5516b31c41440ba621d49656d69f7f1af2f555cf1a708a0d20d4ef2d20c79c1d0e9e789eeec8d743c90005ec1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
