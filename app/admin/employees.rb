ActiveAdmin.register Employee do
  permit_params :first_name,
                :last_name,
                :nickname,
                :active,
                :status,
                :employee_type,
                :email,
                :password,
                :password_confirmation

  actions :all, except: [ :destroy ]

  remove_filter :reimbursements, :reimbursement_items
  config.sort_order = "id_asc"

  index do
    id_column

    column :first_name
    column :last_name
    column :nickname
    column :email
    column :employee_type
    column :active
    column :status do |employee| employee.status.capitalize end
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :nickname
      row :active
      row :email

      row :employee_type do |employee|
        employee.employee_type.capitalize
      end

      row :status do |employee|
        employee.status.capitalize
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :nickname
      f.input :active
      f.input :email
      if f.employee.new_record?
        f.input :password
        f.input :password_confirmation
      end
      f.input :employee_type, as: :select, collection: [ [ "Regular", "regular" ], [ "Contractual", "contractual" ], [ "Probationary", "probationary" ] ], include_blank: false
      f.input :status, as: :select, collection: [ [ "Active", "active" ], [ "Inactive", "inactive" ] ], include_blank: false

      f.actions
    end
  end
end
