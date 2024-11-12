ActiveAdmin.register Category do
  permit_params :name,
                :description,
                :icon,
                :icon_color,
                :status

  remove_filter :reimbursement

  index do
    id_column

    column :name
    column :description
    column :status do |employee| employee.status.capitalize end
    column :created_at
    column :updated_at

    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :icon
      f.input :icon_color

      f.input :status, as: :select, collection: [ "active", "inactive" ], include_blank: false

      f.actions
    end
  end
end
