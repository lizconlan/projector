class User < ActiveRecord::Base
  has_secure_password
  validates_presence_of :password, :on => :create
  
  # to create initial admin user
  def self.create_admin_user(password, login)
    if count > 0
      raise 'admin user already exists'
    elsif password.blank?
      raise 'password cannot be blank'
    elsif login.blank?
      raise 'login cannot be blank'
    else
      User.create!(:login=>login,:password=>password,:password_confirmation=>password)
    end
  end
end