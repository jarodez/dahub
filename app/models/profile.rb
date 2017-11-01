class Profile < ApplicationRecord
  before_save {self.name = name.downcase}
  has_many :profile_roles
  has_many :roles, through: :profile_roles
  validates_presence_of :name
end
