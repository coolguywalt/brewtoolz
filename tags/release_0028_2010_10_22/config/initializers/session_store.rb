# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_brewtoolz_session',
  :secret      => '0b7fecf059c6f280a3db0522fd69245e0d7ae1d6c856be4b6777d1e16977629bdfc4c0cda6d4e7f90a979af0d1fd17a827f58d5d71f6a3b622f953d74b8f09f0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
