ActiveAdmin.register Reimbursement do
  require "zip"

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
  filter :status, as: :select, collection: -> { @status }

  config.sort_order = "activity_date_desc"

  index do
    id_column
    column "Activity", :category_id, class: "admin-table-width-150 text-truncate" do |reimbursement|
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
      f.input :employee_id, as: :select, collection: employees, prompt: "Select Assigned Employee"
      f.input :participated_employee_ids, as: :select, collection: employees, input_html: { multiple: true }
      f.input :category_id, as: :select, collection: categories, prompt: "Select a category"
      f.input :activity_date, as: :datepicker, input_html: { max: Date.today }
      f.input :invoice_reference_number
      f.input :invoice_amount
      f.input :reimbursable_amount
      f.input :reimbursed_amount
      f.input :supplier
      f.input :image, as: :file, hint: f.object.image.attached? ? image_tag(url_for(f.object.image), style: "width: 300px; height: auto;") : content_tag(:span, "No image uploaded")
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

  action_item :export_images, only: :index do
    link_to "Export Images", export_images_admin_reimbursements_path(filter_params: params.permit(q: {}).to_h[:q])
  end

  collection_action :export_images, method: :get do
    reimbursements = handle_reimbursements_filter(params[:filter_params])
    create_temp_zip(reimbursements)
  end

  controller do
    def load_collections
      @employees = Employee.where(status: "active").pluck(:nickname, :id)
      @categories = Category.where(status: "active").pluck(:name, :id)
      @status = { "Pending" => "pending", "Reimbursed" => "reimbursed", "Cancelled" => "cancelled" }
    end

    def participated_employees
      params[:reimbursement][:participated_employee_ids].reject!(&:blank?) if params[:reimbursement][:participated_employee_ids]
    end

    def handle_reimbursements_filter(params)
      reimbursements = Reimbursement.where.not(status: "cancelled").with_attached_image

      if params.present?
        if params[:employee_id].present?
          reimbursements = reimbursements.where(employee_id: params[:employee_id])
        end
  
        if params[:category_id].present?
          reimbursements = reimbursements.where(category_id: params[:category_id])
        end
  
        if params[:status_eq].present?
          reimbursements = reimbursements.where(status: params[:status_eq])
        end
  
        if params[:activity_date_gteq].present? && params[:activity_date_lteq].present?
          start_date = Date.parse(params[:activity_date_gteq])
          end_date = Date.parse(params[:activity_date_lteq])
  
          reimbursements = Reimbursement.where(activity_date: start_date..end_date)
        end
      end

      reimbursements
    end

    def create_temp_zip(reimbursements)
      temp_dir = Rails.root.join("tmp", "invoice_images")

      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
      FileUtils.mkdir_p(temp_dir)

      zip_file_path = temp_dir.join("images.zip")

      download_zip(zip_file_path, reimbursements)
    end

    def download_zip(file_path, reimbursements)
      Zip::File.open(file_path, Zip::File::CREATE) do |zipfile|
        reimbursements.each_with_index do |reimbursement, index|
          if reimbursement.image.attached?
            image_path = ActiveStorage::Blob.service.path_for(reimbursement.image.key)
            image_filename = "#{reimbursement.formatted_activity_date}_#{reimbursement.supplier.upcase}.#{reimbursement.image.filename.extension}"

            zipfile.add(image_filename, image_path)
          end
        end
      end

      send_file file_path, type: "application/zip", disposition: "attachment", filename: "Invoice Images.zip"
    end
  end
end
