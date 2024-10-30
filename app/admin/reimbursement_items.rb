ActiveAdmin.register ReimbursementItem do
  actions :all, except: [:new, :edit, :update, :destroy]

  index do
    id_column
    column :reimbursement_id do |item|
      link_to item.reimbursement.id, admin_reimbursement_path(item.reimbursement.id)
    end
    
    column :employee_id do |item|
      link_to item.employee.nickname, admin_employee_path(item.employee.id)
    end

    column :shared_amount

    actions
  end
  
end