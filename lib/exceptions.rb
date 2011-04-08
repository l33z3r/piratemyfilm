module Exceptions
  class AuthenticationErrors < StandardError; end
  class UserNotActivated < AuthenticationErrors; end
end
