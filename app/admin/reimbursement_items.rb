ActiveAdmin.register ReimbursementItem do
  actions :all, except: [:new, :destroy]

  config.sort_order = 'id_asc'

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
  
end