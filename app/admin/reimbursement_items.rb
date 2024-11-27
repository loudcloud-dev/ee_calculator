ActiveAdmin.register ReimbursementItem do
  actions :all, except: [ :new, :destroy, :edit ]
  before_action :load_collections, only: [ :index ]

  preserve_default_filters!
  remove_filter :reimbursement
  filter :employee, as: :select, collection: -> { @employees }
  config.sort_order = "id_asc"

  index do
    id_column
    column :reimbursement_id do |item|
      link_to item.reimbursement.id, admin_reimbursement_path(item.reimbursement.id)
    end

    column :employee_id do |item|
      link_to item.employee.nickname, admin_employee_path(item.employee.id)
    end

    column :shared_amount, class: "text-end" do |item|
      item.formatted_shared_amount
    end

    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :employee_id do |item|
        link_to item.employee.nickname, admin_employee_path(item.employee.id)
      end

      row :shared_amount do |item|
        item.formatted_shared_amount
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :employee_id, as: :select, collection: employees, prompt: "Select Assigned Employee"
      f.input :shared_amount
    end
  end

  controller do
    def load_collections
      @employees = Employee.where(status: "active").pluck(:nickname, :id)
    end
  end
end
