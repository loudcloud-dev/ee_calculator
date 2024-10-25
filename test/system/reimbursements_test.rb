require "application_system_test_case"

class ReimbursementsTest < ApplicationSystemTestCase
  setup do
    @reimbursement = reimbursements(:one)
  end

  test "visiting the index" do
    visit reimbursements_url
    assert_selector "h1", text: "Reimbursements"
  end

  test "should create reimbursement" do
    visit reimbursements_url
    click_on "New reimbursement"

    fill_in "Activity date", with: @reimbursement.activity_date
    fill_in "Category", with: @reimbursement.category
    fill_in "Employee", with: @reimbursement.employee_id
    fill_in "Invoice amount", with: @reimbursement.invoice_amount
    fill_in "Invoice reference number", with: @reimbursement.invoice_reference_number
    fill_in "Participated employee ids", with: @reimbursement.participated_employee_ids
    fill_in "Reimbursable amount", with: @reimbursement.reimbursable_amount
    fill_in "Reimbursed amount", with: @reimbursement.reimbursed_amount
    fill_in "Status", with: @reimbursement.status
    fill_in "Supplier", with: @reimbursement.supplier
    click_on "Create Reimbursement"

    assert_text "Reimbursement was successfully created"
    click_on "Back"
  end

  test "should update Reimbursement" do
    visit reimbursement_url(@reimbursement)
    click_on "Edit this reimbursement", match: :first

    fill_in "Activity date", with: @reimbursement.activity_date.to_s
    fill_in "Category", with: @reimbursement.category
    fill_in "Employee", with: @reimbursement.employee_id
    fill_in "Invoice amount", with: @reimbursement.invoice_amount
    fill_in "Invoice reference number", with: @reimbursement.invoice_reference_number
    fill_in "Participated employee ids", with: @reimbursement.participated_employee_ids
    fill_in "Reimbursable amount", with: @reimbursement.reimbursable_amount
    fill_in "Reimbursed amount", with: @reimbursement.reimbursed_amount
    fill_in "Status", with: @reimbursement.status
    fill_in "Supplier", with: @reimbursement.supplier
    click_on "Update Reimbursement"

    assert_text "Reimbursement was successfully updated"
    click_on "Back"
  end

  test "should destroy Reimbursement" do
    visit reimbursement_url(@reimbursement)
    click_on "Destroy this reimbursement", match: :first

    assert_text "Reimbursement was successfully destroyed"
  end
end
