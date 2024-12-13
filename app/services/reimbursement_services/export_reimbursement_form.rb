module ReimbursementServices
  class ExportReimbursementForm < ApplicationService
    include ActionView::Helpers::NumberHelper

    require "prawn"
    require "zip"

    def initialize(params)
      @filter_params = params
      @month = Date::MONTHNAMES[@filter_params[:activity_date].to_i]
    end

    def perform
      process
    end

    private

    def process
      reimbursements = reimbursements(@filter_params)
      generate_pdfs(reimbursements)
    end

    def reimbursements(params)
      reimbursements = Reimbursement.joins(:employee)
                                    .joins(:category)
                                    .where(status: "reimbursed")
                                    .order(activity_date: "desc")

      if params[:activity_date].present?
        month = params[:activity_date].to_i

        start_date = Date.new(Date.today.year, month, 6)
        end_date = (start_date + 1.month) - 1.day

        reimbursements = reimbursements.where(activity_date: start_date..end_date)
      end

      reimbursements
    end

    def generate_pdfs(reimbursements)
      pdfs = []
      reimbursements.group_by(&:employee_id).each do |id, reimbursements|
        employee = Employee.find(id)

        pdf = Prawn::Document.new

        # Set pdf font
        pdf.font_families.update(
          "Nunito" => {
            normal: Rails.root.join("app", "assets", "fonts", "Nunito-Regular.ttf").to_s,
            bold: Rails.root.join("app", "assets", "fonts", "Nunito-Bold.ttf").to_s,
            italic: Rails.root.join("app", "assets", "fonts", "Nunito-Italic.ttf").to_s
          }
        )
        pdf.font "Nunito"

        # Header: Logo, Address, and Email
        pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
          pdf.image Rails.root.join("app", "assets", "images", "loudcloud_logo.png").to_s, width: 115, height: 45, at: [ 0, pdf.cursor ]

          pdf.bounding_box([ 220, pdf.cursor ], width: pdf.bounds.width - 220) do
            pdf.move_down 20
            pdf.text "1 Champaca St., Roxas District, Quezon City", align: :right, size: 10
            pdf.text "Email: info@loudcloud.ph", align: :right, size: 10
          end
        end

        # Header Title
        pdf.move_down 25
        pdf.text "LoudCloud Employee Engagement Availment Reimbursement Form", align: :center, size: 14, style: :bold
        pdf.text "(Paid by Electronic Transfer)", align: :center, size: 10

        # Payee Details: Employee, Month
        pdf.move_down 10
        pdf.text "Payee Details", size: 12, style: :bold
        pdf.move_down 3

        # Employee
        employee_name = employee.first_name.present? ? "#{employee.first_name} #{employee.last_name}" : employee.nickname
        pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
          pdf.text_box "Employee:", size: 10, style: :bold, at: [ 0, pdf.cursor ], width: 52
          pdf.text_box employee_name, size: 10, at: [ 52, pdf.cursor ], width: pdf.bounds.width - 52
        end
        pdf.move_down 15

        # Month
        pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
          pdf.text_box "Availments for the Month of:", size: 10, style: :bold, at: [ 0, pdf.cursor ], width: 137
          pdf.text_box @month, size: 10, at: [ 137, pdf.cursor ], width: pdf.bounds.width - 137
        end
        pdf.move_down 15

        transaction_ids = reimbursements.map(&:transaction_id).join(", ")
        unique_transaction_ids = transaction_ids.split(",").map(&:strip).uniq.join(", ")

        pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
          pdf.text_box "Transaction ID:", size: 10, style: :bold, at: [ 0, pdf.cursor ], width: 75
          pdf.text_box unique_transaction_ids, size: 10, at: [ 75, pdf.cursor ], width: pdf.bounds.width - 75
        end
        pdf.move_down 15

        # Item breakdown
        total_amount = reimbursements.sum { |reimbursement| reimbursement.invoice_amount || 0 }
        table_data = [ [ "Activity", "Partner", "Supplier", "OR Ref #", "Paid On", "Amount Paid" ] ]

        reimbursements.each do |reimbursement|
          activity_details = "#{reimbursement.category.name}\n#{reimbursement.activity_date.strftime('%b %d, %Y')}"
          participated_employees = reimbursement.participated_employees.map do |employee|
            employee.active ? employee.nickname : "#{employee.nickname} (Inactive)"
          end.join(", ")

          table_data << [
            activity_details,
            participated_employees,
            reimbursement.supplier,
            reimbursement.invoice_reference_number,
            reimbursement.updated_at.strftime("%b %d, %Y"),
            format_amount(reimbursement.invoice_amount)
          ]
        end

        table_data << [ "", "", "", "", "Total:", format_amount(total_amount) ]

        # Render table
        pdf.table(table_data, header: true, width: pdf.bounds.width) do |t|
          t.column_widths = [ 80, 110, 120, 60, 80, 90 ]
          t.header = true
          t.row(0).style(background_color: "f8f9fa", font_style: :bold, align: :center)
          t.row(-1).style(background_color: "bfebfe", font_style: :bold)
          t.cells.style(border_width: 1, padding: 5, align: :left, size: 10)

          t.column(5).style(align: :right)
        end

        # Footer
        pdf.move_down 10
        pdf.text "NOTE: Voucher generated from Loudcloud EE App on #{Date.today.strftime('%B %d, %Y')}. No taxes have been withheld, or can be claimed, from this payment.", size: 10, color: "FF0000", font_style: :bold

        pdfs << { employee: employee, pdf: pdf.render }
      end

      create_temp_zip(pdfs)
    end

    def create_temp_zip(pdfs)
      temp_dir = Rails.root.join("tmp", "reimbursement_forms")

      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
      FileUtils.mkdir_p(temp_dir)

      zip_file_path = temp_dir.join("forms.zip")

      download_zip(zip_file_path, pdfs)
      zip_file_path
    end

    def download_zip(file_path, pdfs)
      Zip::File.open(file_path, Zip::File::CREATE) do |zipfile|
        pdfs.each do |pdf|
          filename = "#{pdf[:employee].nickname} - Reimbursement Form (#{@month}).pdf"
          zipfile.get_output_stream(filename) { |f| f.write(pdf[:pdf]) }
        end
      end
    end

    def format_amount(amount)
      number_to_currency(amount, unit: "₱")
    end
  end
end
