module Spree
  class PaymentMethod::CashOnDelivery < ::Spree::PaymentMethod
    TOTAL_TIER = 10

    preference :tax_category_id, :integer
    preference :tier1_threshold, :decimal, default: 10_000.0
    preference :tier1_fee, :decimal, default: 330.0

    preference :tier2_threshold, :decimal, default: 30_000.0
    preference :tier2_fee, :decimal, default: 440.0

    preference :tier3_threshold, :decimal, default: 50_000.0
    preference :tier3_fee, :decimal, default: 550.0

    preference :tier4_threshold, :decimal, default: 100_000.0
    preference :tier4_fee, :decimal, default: 660.0

    preference :tier5_threshold, :decimal, default: 150_000.0
    preference :tier5_fee, :decimal, default: 770.0

    preference :tier6_threshold, :decimal, default: 200_000.0
    preference :tier6_fee, :decimal, default: 880.0

    preference :tier7_threshold, :decimal, default: 300_000.0
    preference :tier7_fee, :decimal, default: 990.0

    preference :tier8_threshold, :decimal, default: 400_000.0
    preference :tier8_fee, :decimal, default: 1_100.0

    preference :tier9_threshold, :decimal, default: 500_000.0
    preference :tier9_fee, :decimal, default: 1_210.0

    preference :tier10_threshold, :decimal, default: 1_000_000.0
    preference :tier10_fee, :decimal, default: 1_320.0

    preference :max_fee, :decimal, default: 1_500.0

    def calculate_service_fee(order)
      # 購入金額 = 小計 + オプション(名入れ料金など) - 会員割引など
      # 商品小計
      item_total = order.item_total

      # 商品レベルの調整額（名入れ料金などのオプション）
      line_item_adj_total = BigDecimal(
        order.line_item_adjustments.nonzero.promotion.eligible.sum(:amount).to_s
      ).round(2, BigDecimal::ROUND_HALF_UP)

      # 注文レベルの調整額（会員割引など）- 税金と決済方法手数料を除く
      order_adj_total = BigDecimal(
        order.adjustments.nonzero.non_tax.non_payment_method.eligible.sum(:amount).to_s
      ).round(2, BigDecimal::ROUND_HALF_UP)

      total = item_total + line_item_adj_total + order_adj_total

      return preferred_tier1_fee if total <= preferred_tier1_threshold
      return preferred_tier2_fee if total <= preferred_tier2_threshold
      return preferred_tier3_fee if total <= preferred_tier3_threshold
      return preferred_tier4_fee if total <= preferred_tier4_threshold
      return preferred_tier5_fee if total <= preferred_tier5_threshold
      return preferred_tier6_fee if total <= preferred_tier6_threshold
      return preferred_tier7_fee if total <= preferred_tier7_threshold
      return preferred_tier8_fee if total <= preferred_tier8_threshold
      return preferred_tier9_fee if total <= preferred_tier9_threshold
      return preferred_tier10_fee if total <= preferred_tier10_threshold

      preferred_max_fee
    end

    def create_cod_fee_adjustment!(order, eligible = true)
      adjustment = order.adjustments.new
      adjustment.source = self
      adjustment.order = order
      adjustment.amount = calculate_service_fee(order)
      adjustment.label = service_fee_label
      adjustment.eligible = eligible
      adjustment.save!
      adjustment
    end

    def payment_profiles_supported?
      true # we want to show the confirm step.
    end

    def authorize(*)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def capture(payment, source, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def auto_capture?
      true
    end

    def void(*)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def cancel(*)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def actions
      %w{capture void}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def source_required?
      false
    end

    def payment_source_class
      nil
    end

    def method_type
      'cash_on_delivery'
    end

    def custom_form_fields_partial_name
      'cash_on_delivery_form_fields'
    end

    class << self
      def destroy_cod_fee_adjustments(order)
        order.adjustments.where(label: service_fee_label).destroy_all
      end

      def service_fee_label
        I18n.t('cash_on_delivery.service_fee_label')
      end
    end

    delegate :service_fee_label, to: :class
  end
end
