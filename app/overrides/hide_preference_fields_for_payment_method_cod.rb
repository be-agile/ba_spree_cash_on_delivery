Deface::Override.new(
  virtual_path: 'spree/admin/payment_methods/_form',
  name: 'hide_preference_fields_for_payment_method_cod',
  replace: "erb[loud]:contains('preference_fields(@object, f)')",
  text: <<-HTML
    <% unless @object.is_a?(Spree::PaymentMethod::CashOnDelivery) %>
      <%= preference_fields(@object, f) unless preference_fields(@object, f).empty? %>
    <% end %>
  HTML
)
