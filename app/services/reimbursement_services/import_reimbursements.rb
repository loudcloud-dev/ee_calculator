module ReimbursementServices
  class ImportReimbursements < ApplicationService
    require 'open-uri'

    def initialize(csv_link)
      @csv_link = csv_link
    end

    def perform
      process
    end

    private

    def process
      csv_content = URI.open(@csv_link).read
      return unless csv_content.present?

      import_data(csv_content)
    end

    def import_data(csv)
      rows = CSV.parse(csv, headers: true, col_sep: ";")
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
