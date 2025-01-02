ActiveAdmin.register Leave do
  permit_params :employee_id,
                :approver_id,
                :start_date,
                :end_date,
                :day_count,
                :leave_type,
                :reason,
                :status

  actions :all, except: [ :destroy ]

  action_item :approve, only: :show, if: proc { resource.status == "pending" } do
    link_to "Approve", approve_admin_leave_path(resource), method: :put, class: "button"
  end

  action_item :reject, only: :show, if: proc { resource.status == "pending" } do
    link_to "Reject", reject_admin_leave_path(resource), method: :put, class: "button"
  end

  member_action :approve, method: :put do
    resource.update(status: "approved", processed_by: current_admin_user)
    redirect_to admin_leaves_path, notice: "Leave approved!"
  end

  member_action :reject, method: :put do
    resource.update(status: "rejected", processed_by: current_admin_user)
    redirect_to admin_leaves_path, notice: "Leave rejected!"
  end

  filter :employee, as: :select, collection: Employee.joins(:leaves).distinct.pluck(:nickname, :id)
  filter :approver_id, as: :select, collection: AdminUser.all.pluck(:email, :id)
  filter :start_date, as: :date_range
  filter :end_date, as: :date_range
  filter :leave_type, as: :select, collection: { "Sick" => "sick", "Vacation" => "vacation" }
  filter :status, as: :select, collection: { "Pending" => "pending", "Approved" => "approved", "Rejected" => "rejected", "Cancelled" => "cancelled" }

  index do
    id_column
    column :employee do |leave| leave.employee.nickname end
    column :approver
    column :start_date
    column :end_date
    column :day_count
    column :leave_type do |leave| leave.leave_type.capitalize end
    column :status do |leave|
      status_tag leave.status, class: get_status_class(leave.status)
    end
    column :updated_at

    actions defaults: true do |leave|
      if leave.status == "pending"
        links = [
          link_to("Approve", approve_admin_leave_path(leave), method: :put, class: "member_link btn-sm"),
          link_to("Reject", reject_admin_leave_path(leave), method: :put, class: "member_link btn-sm")
        ]
        safe_join(links)
      end
    end
  end

  show do
    attributes_table do
      row :employee do |leave| leave.employee.nickname end
      row :approver
      row :start_date
      row :end_date
      row :day_count
      row :leave_type do |leave| leave.leave_type.capitalize end
      row :reason
      row :status do |leave|
        status_tag leave.status, class: get_status_class(leave.status)
      end
      row :created_at
      row :updated_at
      row :processed_by
    end
  end

  form do |f|
    f.inputs do
      f.input :employee_id, as: :select, collection: Employee.all.pluck(:nickname, :id), prompt: "Select Employee"
      f.input :approver_id, as: :select, collection: AdminUser.all.pluck(:email, :id), prompt: "Select Approver"
      f.input :start_date, as: :datepicker, input_html: { min: Date.today }
      f.input :end_date, as: :datepicker, input_html: { min: Date.today }
      f.input :day_count, as: :number
      f.input :leave_type, as: :radio, collection: { "Sick" => "sick", "Vacation" => "vacation" }, prompt: "Select Leave Type"
      f.input :reason
      f.input :status, as: :select, collection: { "Pending" => "pending", "Approved" => "approved", "Rejected" => "rejected", "Cancelled" => "cancelled" }, prompt: "Select Status"

      f.actions
    end
  end

  controller do
    helper_method :get_status_class

    def get_status_class(status)
      if status == "approved"
        "green"
      elsif status == "rejected"
        "red"
      elsif status == "pending"
        "orange"
      else
        "gray"
      end
    end
  end
end
