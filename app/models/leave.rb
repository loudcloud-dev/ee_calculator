class Leave < ApplicationRecord
  belongs_to :employee
  belongs_to :approver, class_name: "AdminUser"
end
