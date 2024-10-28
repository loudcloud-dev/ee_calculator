ActiveAdmin.register Category do
  permit_params :name,
                :description

  form do |f|
    f.inputs do
      f.input :name
      f.input :description

      f.input :status, as: :select, collection: ['active', 'inactive'], include_blank: false

      f.actions
    end
  end
end