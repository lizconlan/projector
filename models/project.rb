class Project < ActiveRecord::Base
  has_many :repositories, :live_sites
end