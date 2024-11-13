ActiveAdmin.register Reimbursement do
  permit_params :employee_id,
                :category_id,
                :activity_date,
                :invoice_reference_number,
                :invoice_amount,
                :image,
                :reimbursable_amount,
                :reimbursed_amount,
                :supplier,
                :status,
                participated_employee_ids: []

  # Actions
  before_action :participated_employees, only: [ :create, :update ]
  before_action :load_collections, only: [ :index, :new, :edit ]
  actions :all, except: [ :destroy ]

  # Filters
  preserve_default_filters!
  remove_filter :image_attachment, :image_blob, :reimbursement_items
  filter :employee, as: :select, collection: -> { @employees }
  config.sort_order = "activity_date_desc"

  index do
    id_column

    column :employee_id do |reimbursement|
      link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
    end

    column "Participated Employees", :participated_employee_ids do |reimbursement|
      reimbursement.participated_employees.map(&:nickname).join(", ")
    end

    column :category_id do |reimbursement|
      category = Category.find_by(id: reimbursement.category_id, status: "active")
      category.name
    end

    column :activity_date
    column :invoice_reference_number
    column :invoice_amount
    column "Invoice Image", :image do |reimbursement|
      if reimbursement.image.attached?
        link_to "View Image", url_for(reimbursement.image), target: "_blank", class: "text-primary"
      end
    end
    column :reimbursable_amount
    column :reimbursed_amount
    column :supplier
    column :status do |employee| employee.status.capitalize end

    actions
  end

  show do
    attributes_table do
      row :id
      row :employee_id do |reimbursement|
        link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
      end

      row :participated_employee_ids do |reimbursement|
        reimbursement.participated_employees.map(&:nickname).join(", ")
      end

      row :category_id
      row :activity_date
      row :invoice_reference_number
      row :invoice_amount
      row :reimbursable_amount
      row :reimbursed_amount
      row "Invoice Image", :image do |reimbursement|
        if reimbursement.image.attached?
          link_to "View Image", url_for(reimbursement.image), target: "_blank", class: "text-primary"
        end
      end
      row :supplier
      row :status
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :employee_id, as: :select, collection: employees, prompt: "Select Assigned Employee"
      f.input :participated_employee_ids, as: :select, collection: employees, input_html: { multiple: true }
      f.input :category_id, as: :select, collection: categories, prompt: "Select a category"
      f.input :activity_date, as: :datepicker, input_html: { max: Date.today }
      f.input :invoice_reference_number
      f.input :invoice_amount
      f.input :reimbursable_amount
      f.input :reimbursed_amount
      f.input :supplier
      f.input :status, as: :select, collection: [ [ "Pending", "pending" ], [ "Reimbursed", "reimbursed" ], [ "Cancelled", "cancelled" ] ], include_blank: false
    end

    f.actions
  end

  controller do
    def load_collections
      @employees = Employee.where(status: "active").pluck(:nickname, :id)
      @categories = Category.where(status: "active").pluck(:name, :id)
    end

    def participated_employees
      params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
    end
  end
end
