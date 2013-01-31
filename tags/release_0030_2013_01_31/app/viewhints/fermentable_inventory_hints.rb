class FermentableInventoryHints < Hobo::ViewHints

     field_help :amount => "Amount of item in stock",
       :comment => "Notes on the item stored",
       :location => "Place where stored",
       :label => "Labeling on the item",
       :source_date => "Date the item was sourced, used to estimated the age of the item."
end
