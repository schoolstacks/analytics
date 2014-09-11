require "./lib/lt_base.rb"
require "./lib/model/user.rb"
require "./lib/model/api_key.rb"
require "./lib/util/redis_server.rb"

module LT
  module SessionManager
    class << self
      def validate_user(username, password)
        # Method will validate a user in the data model, if user is valid,
        # will create an API key in data model, then insert it into Redis

        if username.nil? || username.empty? || password.nil? || password.empty? then
          raise LT::ParameterMissing, "Username or password is not provided"
        else
          # TODO: Think about logic to re-use api key if session is already active
          user = User.get_validated_user(username, password).fetch(:user)
          api_key = ApiKey.create_api_key(user.id)
          # TODO: Refactor to use active ActiveRecord connection from LT base
          db_name = LT::get_db_name(File::expand_path('./db/config.yml'))
          LT::RedisServer.api_key_set(api_key, db_name)
          return api_key
        end # if / else
      end # def ValidateUser
    end # class << self
  end # module SessionManager
end # module LT
