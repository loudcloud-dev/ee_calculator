class AdminUser < ApplicationRecord
  has_many :assigned_leaves, class_name: "Leave", foreign_key: "approver_id"
  has_many :processed_leaves, class_name: "Leave", foreign_key: "processed_by_id"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
