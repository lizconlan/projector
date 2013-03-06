class Project < ActiveRecord::Base
  has_many :repositories
  has_many :live_sites
end