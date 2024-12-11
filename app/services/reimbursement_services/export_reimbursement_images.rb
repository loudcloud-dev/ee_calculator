module ReimbursementServices
  class ExportReimbursementImages < ApplicationService
    require "zip"

    def initialize(params)
      @filter_params = params
    end

    def perform
      process
    end

    private

    def process
      reimbursements = handle_reimbursements_filter(@filter_params)
      create_temp_zip(reimbursements)
    end

    def handle_reimbursements_filter(params)
      reimbursements = Reimbursement.where.not(status: "cancelled").with_attached_image

      if params.present?
        reimbursements = reimbursements.where(employee_id: params[:employee_id_eq]) if params[:employee_id_eq].present?
        reimbursements = reimbursements.where(category_id: params[:category_id]) if params[:category_id].present?
        reimbursements = reimbursements.where(status: params[:status_eq]) if params[:status_eq].present?

        if params[:activity_date_gteq].present? || params[:activity_date_lteq].present?
          start_date = Date.parse(params[:activity_date_gteq])
          end_date = params[:activity_date_lteq].present? ? Date.parse(params[:activity_date_lteq]) : Date.today

          reimbursements = reimbursements.where(activity_date: start_date..end_date)
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
      zip_file_path
    end

    def download_zip(file_path, reimbursements)
      max_filename_length = 255

      Zip::File.open(file_path, Zip::File::CREATE) do |zipfile|
        reimbursements.each_with_index do |reimbursement, index|
          if reimbursement.image.attached?
            date = reimbursement.activity_date.strftime("%m%d%Y")
            supplier = reimbursement.supplier.upcase
            invoice_reference_number = reimbursement.invoice_reference_number
            extension = reimbursement.image.filename.extension

            image_path = ActiveStorage::Blob.service.path_for(reimbursement.image.key)
            image_filename = "#{date}_#{supplier}_#{invoice_reference_number}.#{extension}"

            if image_filename.length > max_filename_length
              supplier = reimbursement.supplier.upcase[0, 50]
              invoice_reference = reimbursement.invoice_reference_number[0, 50]
              image_filename = "#{date}_#{supplier}_#{invoice_reference}.#{extension}"
            end

            zipfile.add(image_filename, image_path)
          end
        end
      end
    end
  end
end
