class User < ActiveRecord::Base

  has_many :domains

  include SDB::Helpers

  before_save  :generate_secret_and_key

  protected
  
  def generate_secret_and_key
    if self.key.blank?
        self.key = generate_key
        self.secret = generate_secret
    end
  end

end
