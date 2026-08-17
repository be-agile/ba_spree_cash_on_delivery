Deface::Override.new(
  virtual_path: 'spree/shared/_order_details',
  name: 'add_cod_fee_adjustment_to_order_details',
  insert_before: ".flex.items-center.justify-between.border-default.border-t.font-medium",
  text: <<-HTML
    <% cod_fee_adjustment = @order.cod_fee_adjustment %>
    <% if cod_fee_adjustment.present? %>
      <div class="flex items-center justify-between py-2" id="cod_fee_adjustment">
        <div>
          <%= cod_fee_adjustment.label %>
        </div>
        <div>
          <%= cod_fee_adjustment.display_amount.to_html %>
        </div>
      </div>
    <% end %>
  HTML
)
