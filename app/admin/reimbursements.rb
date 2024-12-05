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
  before_action :load_collections, only: [ :index, :new, :create, :edit, :update ]
  actions :all, except: [ :destroy ]

  # Filters
  preserve_default_filters!
  remove_filter :image_attachment, :image_blob, :reimbursement_items, :participated_employee_ids

  filter :employee, as: :select, collection: -> { @employees }
  filter :status, as: :select, collection: -> { @status }

  config.sort_order = "activity_date_desc"
  menu false

  batch_action :update_status, confirm: "Are you sure you want to update the selected reimbursements?", form: {
    status: [ [ "Pending", "pending" ], [ "Reimbursed", "reimbursed" ], [ "Cancelled", "cancelled" ] ]
  } do |ids, inputs|
    batch_action_collection.find(ids).each do |reimbursement|
      reimbursement.update(status: inputs[:status])
    end

    redirect_to admin_reimbursements_path, notice: "Selected reimbursements have been updated to #{inputs[:status]}."
  end

  index do
    id_column
    selectable_column
    column "Activity", :category_id, class: "admin-table-width-150 text-truncate" do |reimbursement|
      category = Category.find_by(id: reimbursement.category_id)
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

    column "Reimbursed To", :employee_id do |reimbursement|
      link_to reimbursement.employee.nickname, admin_employee_path(reimbursement.employee)
    end

    column "Participated Employees", :participated_employee_ids, class: "admin-table-width-180 text-break" do |reimbursement|
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

    div class: "index-footer-summary" do
      reimbursements = Reimbursement.where.not(status: "cancelled")

      if params[:q].present?
        reimbursements = reimbursements.where(employee_id: params[:q][:employee_id_eq]) if params[:q][:employee_id_eq].present?
        reimbursements = reimbursements.where(category_id: params[:q][:category_id]) if params[:q][:category_id].present?
        reimbursements = reimbursements.where(status: params[:q][:status_eq]) if params[:q][:status_eq].present?

        if params[:q][:activity_date_gteq].present? || params[:q][:activity_date_lteq].present?
          start_date = Date.parse(params[:q][:activity_date_gteq])
          end_date = params[:q][:activity_date_lteq].present? ? Date.parse(params[:q][:activity_date_lteq]) : Date.today

          reimbursements = reimbursements.where(activity_date: start_date..end_date)
        end
      end

      total_invoice_amount = reimbursements.sum(:invoice_amount)
      total_reimbursable_amount = reimbursements.sum(:reimbursable_amount)

      div do
        span "Total Invoice Amount: ", class: "amount-sum"
        span number_to_currency(total_invoice_amount, unit: "₱")
      end

      div do
        span "Total Reimbursable Amount: ", class: "amount-sum"
        span number_to_currency(total_reimbursable_amount, unit: "₱")
      end
    end
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

      row :category_id do |reimbursement|
        category = Category.find_by(id: reimbursement.category_id, status: "active")
        category.name
      end

      row :activity_date do |reimbursement|
        reimbursement.formatted_activity_date
      end

      row :invoice_reference_number

      row :invoice_amount do |reimbursement|
        reimbursement.formatted_invoice_amount
      end

      row :reimbursable_amount do |reimbursement|
        reimbursement.formatted_reimbursable_amount
      end

      row :reimbursed_amount do |reimbursement|
        reimbursement.formatted_reimbursed_amount
      end

      row "Invoice Image", :image do |reimbursement|
        if reimbursement.image.attached?
          div do
            link_to "View", url_for(reimbursement.image), target: "_blank", class: "text-primary"
          end
          div do
            link_to "Download", url_for(reimbursement.image), download: true, target: "_blank", class: "text-primary"
          end
        end
      end
      row :supplier
      row :status do |employee| employee.status.capitalize end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :employee_id, as: :select, collection: active_employees, prompt: "Select Assigned Employee"
      f.input :participated_employee_ids,
              label: "Participated Employees",
              as: :select,
              collection: employees.map { |employee|
                nickname = employee.active ? employee.nickname : "#{employee.nickname} (Inactive)"
                [nickname, employee.id]
              },
              input_html: { multiple: true }
      f.input :category_id, as: :select, collection: categories, prompt: "Select a category"
      f.input :activity_date, as: :datepicker, input_html: { max: Date.today }
      f.input :invoice_reference_number

      if f.object.new_record?
        f.input :invoice_amount, input_html: { min: 1, max: 1000000, step: 1 }
      else
        f.input :invoice_amount, input_html: { readonly: true, class: "disabled" }
      end

      f.input :reimbursed_amount
      f.input :supplier
      f.input :image, 
        as: :file, 
        hint: f.object.image.attached? && !f.object.new_record? ? image_tag(url_for(f.object.image), style: "width: 300px; height: auto;") : content_tag(:span, "No image uploaded"), 
        input_html: { accept: "image/*" }
      f.input :status,
        as: :select,
        collection: [ [ "Pending", "pending" ], [ "Reimbursed", "reimbursed" ], [ "Cancelled", "cancelled" ] ],
        include_blank: false
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

  action_item :export_images, only: :index do
    link_to "Export Images", export_images_admin_reimbursements_path(filter_params: params.permit(q: {}).to_h[:q])
  end

  collection_action :export_images, method: :get do
    zip_file_path = ReimbursementServices::ExportReimbursementImages.call(params[:filter_params])

    send_file zip_file_path, type: "application/zip", disposition: "attachment", filename: "Invoice Images.zip"
  end  

  controller do
    def create
      reimbursement_params = params.require(:reimbursement).permit!
      service = ReimbursementServices::CreateReimbursement.call(reimbursement_params)

      if service[:success]
        redirect_to admin_reimbursements_path, notice: "Reimbursement created successfully."
      else
        @reimbursement = Reimbursement.new(reimbursement_params)
        flash.now[:error] = service[:errors].join(", ")

        render :new
      end
    end

    #
    def load_collections
      @employees = Employee.where(status: "active")
      @active_employees = Employee.where(status: "active", active: true).order(:nickname).pluck(:nickname, :id)
      @categories = Category.where(status: "active").pluck(:name, :id)
      @status = { "Pending" => "pending", "Reimbursed" => "reimbursed", "Cancelled" => "cancelled" }

      if params[:q].present?
        @amounts = Reimbursement.select("SUM(invoice_amount), SUM(reimbursable_amount)")
      end
    end

    def participated_employees
      params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
    end
  end
end
