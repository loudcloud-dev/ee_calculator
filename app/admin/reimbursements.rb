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

  action_item only: :index do
    link_to "Import Data", admin_import_reimbursement_data_path, method: :post
  end

  collection_action :import_data, method: :post do
    import_data
  end

  controller do
    def load_collections
      @employees = Employee.where(status: "active").pluck(:nickname, :id)
      @categories = Category.where(status: "active").pluck(:name, :id)
    end

    def participated_employees
      params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
    end

    def import_data
      file_path = File.read("AllResponses.csv")
      return unless file_path.present?

      rows = CSV.parse(file_path, headers: true, col_sep: ";")
      sorted_rows = rows.sort_by { |row| DateTime.strptime(row["Date"], "%m/%d/%y") }

      sorted_rows.each do |row|
        activity = row["Activity"]
        activity_date = DateTime.strptime(row["Date"], "%m/%d/%y")
        participated_employees = row["Employee Names"].split(", ")
        supplier = row["Supplier"]
        invoice_reference_number = row["Invoice Ref #"]
        invoice_amount = row["Invoice Total"].gsub(/[^\d.]/, "").to_f

        # Populate employees table and collect IDs
        participated_employee_ids = find_or_create_employee_on_import(participated_employees)

        # Create reimbursement record
        csv_data = {
          activity: activity,
          activity_date: activity_date,
          participated_employees: participated_employee_ids,
          supplier: supplier,
          invoice_reference_number: invoice_reference_number,
          invoice_amount: invoice_amount
        }

        create_reimbursement_on_import(csv_data)
      end
    end

    def find_or_create_employee_on_import(employees)
      employees.map do |nickname|
        Employee.find_or_create_by!(nickname: nickname).id
      end
    end

    def create_reimbursement_on_import(data)
      filing_employee = Employee.find_by(id: data[:participated_employees].first)
      category = Category.find_by(name: data[:activity])

      reimbursement_params = {
        employee_id: filing_employee.id,
        category_id: category.id,
        activity_date: data[:activity_date],
        invoice_reference_number: data[:invoice_reference_number],
        invoice_amount: data[:invoice_amount],
        participated_employee_ids: data[:participated_employees],
        supplier: data[:supplier]
      }

      ReimbursementServices::CreateReimbursement.call(reimbursement_params)
    end
  end
end
