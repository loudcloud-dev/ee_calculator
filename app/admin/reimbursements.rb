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
    column "Activity", :category_id, class: 'admin-table-width-150 text-truncate' do |reimbursement|
      category = Category.find_by(id: reimbursement.category_id, status: "active")
      div do
        span category.name
        div class: "text-muted" do
          span reimbursement.formatted_activity_date
        end
      end      
    end

    column :supplier do |reimbursement|
      div do
        span reimbursement.supplier
        div class: "text-muted" do
          span "Reference number: #{reimbursement.invoice_reference_number}"
        end
      end 
    end

    column :employee_id do |reimbursement|
      link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
    end

    column "Participated Employees", :participated_employee_ids, class: 'admin-table-width-180 text-break' do |reimbursement|
      reimbursement.participated_employees.map(&:nickname).join(", ")
    end

    column :invoice_amount, class: "text-end" do |reimbursement|
      reimbursement.formatted_invoice_amount
    end
      
    column :reimbursable_amount, class: "text-end" do |reimbursement|
      reimbursement.formatted_reimbursable_amount
    end

    column :reimbursed_amount, class: "text-end" do |reimbursement|
      reimbursement.formatted_reimbursed_amount
    end

    column "Invoice Image", :image do |reimbursement|
      if reimbursement.image.attached?
        div do
          link_to "View", url_for(reimbursement.image), target: "_blank", class: "text-primary"
        end
        div do
          link_to "Download", url_for(reimbursement.image), download: true, target: "_blank", class: "text-primary"
        end
      end
    end
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

  csv do
    column "Activity" do |reimbursement|
      category = Category.find_by(id: reimbursement.category_id, status: "active")
      category.name
    end

    column "Date" do |reimbursement|
      reimbursement.formatted_activity_date
    end

    column "Employee" do |reimbursement|
      reimbursement.employee.nickname
    end

    column :supplier
    column :invoice_reference_number
    column :invoice_amount do |reimbursement|
      reimbursement.formatted_invoice_amount
    end
      
    column :reimbursable_amount do |reimbursement|
      reimbursement.formatted_reimbursable_amount
    end

    column :reimbursed_amount do |reimbursement|
      reimbursement.formatted_reimbursed_amount
    end

    column "Participated Employees" do |reimbursement|
      reimbursement.participated_employees.map do |employee|
        reimbursement_items = ReimbursementItem.where(reimbursement_id: reimbursement.id, employee_id: employee.id)

        reimbursement_items.map do |item|
          "#{employee.nickname} - #{item.formatted_shared_amount}"
        end.join(", ")
      end.join(", ")
    end

    column "Invoice Image" do |reimbursement|
      if reimbursement.image.attached?
        base_url = request.original_url.split("/")[0..2].join("/")
        image_url = url_for(reimbursement.image)

        "#{base_url}#{image_url}"
      end
    end
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
