ActiveAdmin.register Reimbursement do
  permit_params :employee_id,
                :category,
                :activity_date,
                :invoice_reference_number,
                :invoice_amount,
                :reimbursable_amount,
                :reimbursed_amount,
                :supplier,
                :status,
                participated_employee_ids: []

  before_action :participated_employees, only: [:create, :update]

  preserve_default_filters!
  filter :employee, as: :select, collection: -> { Employee.all.map { |employee| [employee.nickname, employee.id] } }
  config.sort_order = 'activity_date_desc'
 
  actions :all, except: [:destroy]

  index do
    id_column

    column :employee_id do |reimbursement|
      link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
    end

    column "Participated Employees", :participated_employee_ids do |reimbursement|
      reimbursement.participated_employee_ids.map do |id|
        employee = Employee.find(id)

        employee.nickname
      end
    end

    column :category
    column :activity_date
    column :invoice_reference_number
    column :invoice_amount
    column :reimbursable_amount
    column :reimbursed_amount
    column :supplier
    column :status

    actions
  end

  show do
    attributes_table do
      row :id
      row :employee_id do |reimbursement|
        link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
      end
    
      row :participated_employee_ids do |reimbursement|
        reimbursement.participated_employee_ids.map do |id|
          employee = Employee.find(id)

          employee.nickname
        end
      end
    
      row :category
      row :activity_date
      row :invoice_reference_number
      row :invoice_amount
      row :reimbursable_amount
      row :reimbursed_amount
      row :supplier
      row :status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :employee_id, as: :select, collection: Employee.all.map { |employee| [employee.nickname, employee.id] },
              prompt: "Select Assigned Employee"

      f.input :participated_employee_ids, as: :select, collection: Employee.all.map { |e| [e.nickname, e.id] }, 
              input_html: { multiple: true }, label: 'Select Participating Employees'

      f.input :category
      f.input :activity_date, as: :datepicker
      f.input :invoice_reference_number
      f.input :invoice_amount
      f.input :reimbursable_amount
      f.input :reimbursed_amount
      f.input :supplier
      f.input :status, as: :select, collection: ['Pending', 'Reimbursed', 'Cancelled'], include_blank: false
    end
  
    f.actions
  end
  
  controller do
    def participated_employees
      params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
    end
  end
end
