class User < ApplicationRecord
	has_many :submissions
  acts_as_voter
  has_secure_token :api_key

  def self.from_omniauth(auth)
    	where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      	user.provider = auth.provider
      	user.uid = auth.uid
      	user.name = auth.info.name
      	user.oauth_token = auth.credentials.token
      	user.oauth_expires_at = Time.at(auth.credentials.expires_at)
        user.email = auth.info.email
        if !User.where(uid: user.uid).exists?
          user.karma = 1
        end
        user.save!
  	end
  end
end
