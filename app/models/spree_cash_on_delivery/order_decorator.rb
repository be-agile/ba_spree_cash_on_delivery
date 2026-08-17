module SpreeCashOnDelivery
  module OrderDecorator
    def self.prepended(base)
      base.set_callback :updating_from_params, :before, :adjust_cod_fee, prepend: true
      base.state_machine do
        after_transition to: :complete, do: :process_cash_on_delivery_payment
      end
    end

    def cod_fee_adjustment
      adjustments.nonzero.non_tax.eligible.find_by(label: Spree::PaymentMethod::CashOnDelivery.service_fee_label)
    end

    private

    def adjust_cod_fee
      return if payments_attributes.blank?

      destroy_cod_fee_adjustments
      payment_method = find_cod_payment_method
      create_cod_fee_adjustment!(payment_method)
      updater.update
    end

    def find_cod_payment_method
      payment_method_ids = payments_attributes.pluck('payment_method_id')
      # Spree 5.3 で Order#available_payment_methods は deprecated になり、かつ gem 内部で
      # collect_payment_methods(store) を arity 0 のメソッドへ 1 引数で呼ぶ不整合があるため
      # ArgumentError (wrong number of arguments given 1 expected 0) で必ず落ちる。
      # 5.3 推奨の collect_frontend_payment_methods(配列を返す)へ置き換える。
      available_method_ids = collect_frontend_payment_methods.map(&:id)

      Spree::PaymentMethod
        .where(id: payment_method_ids)
        .where(id: available_method_ids)
        .find_by(type: 'Spree::PaymentMethod::CashOnDelivery')
    end

    def destroy_cod_fee_adjustments
      Spree::PaymentMethod::CashOnDelivery.destroy_cod_fee_adjustments(self)
    end

    def create_cod_fee_adjustment!(payment_method)
      return if payment_method.blank?
      payment_method.create_cod_fee_adjustment!(self)
    end

    # spree_np_atobarai の同名 private メソッドと実装が同一。engine ごとにモジュールを分離した
    # 結果、両方が Spree::Order の ancestors に載り外側だけが呼ばれるが、実装が同じなので
    # どちらが外側でも挙動は変わらない。
    # @see https://github.com/be-agile/giga-repeat/issues/1307
    def payments_attributes
      @updating_params&.dig('order', 'payments_attributes') || []
    end

    def process_cash_on_delivery_payment
      payments.includes(:payment_method).each do |payment|
        if payment.payment_method.is_a?(Spree::PaymentMethod::CashOnDelivery) &&
          payment.payment_method.auto_capture? && !payment.send(:has_invalid_state?) && !payment.completed?
          payment.capture!
        end
      end
    end
  end
end

Spree::Order.prepend(SpreeCashOnDelivery::OrderDecorator)
