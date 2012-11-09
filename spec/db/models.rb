class User < ActiveRecord::Base
  attr_accessible :email, :username
end

class Client < ActiveRecord::Base
  attr_accessible :email, :username
end

class Other < ActiveRecord::Base
  attr_accessible :test_mail, :username
end