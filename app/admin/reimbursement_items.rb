ActiveAdmin.register ReimbursementItem do
  actions :all, except: [ :new, :destroy ]
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

    column :shared_amount
    column :created_at
    column :updated_at

    actions
  end

  controller do
    def load_collections
      @employees = Employee.where(status: "active").pluck(:nickname, :id)
    end
  end
end
