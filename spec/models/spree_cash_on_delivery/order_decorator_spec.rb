require 'spec_helper'

RSpec.describe SpreeCashOnDelivery::OrderDecorator, type: :model do
  describe "#update_from_params" do
    subject do
      allow(order.updater).to receive(:update).and_call_original
      order.update_from_params(params, [ payments_attributes: [ :payment_method_id, :amount ] ])
    end

    let!(:store) { create(:store) }
    let(:order) { create(:order_with_line_items, store:, state: 'payment') }
    let!(:cash_on_delivery) { Spree::PaymentMethod::CashOnDelivery.create!(name: '代金引換', stores: [ store ]) }
    let!(:bank_transfer) { create(:check_payment_method, name: '銀行振込', stores: [ store ]) }
    let(:params) { ActionController::Parameters.new(order: { payments_attributes: [ { payment_method_id: payment_method.id } ] }) }
    let(:fee_adjustment) { order.adjustments.find_by(label: Spree::PaymentMethod::CashOnDelivery.service_fee_label) }
    let(:payment_amounts) { order.payments.valid.map(&:amount) }

    context "代金引換を選んだ" do
      let(:payment_method) { cash_on_delivery }

      it do
        expect(subject).to be true
        expect(fee_adjustment.amount).to eq 330
        expect(payment_amounts).to eq [ order.reload.total ]
        expect(order.updater).to have_received(:update)
      end
    end

    context "代金引換から銀行振込に変えた" do
      let(:payment_method) { bank_transfer }

      before do
        cash_on_delivery.create_cod_fee_adjustment!(order)
        order.update_with_updater!
      end

      it do
        expect(subject).to be true
        expect(fee_adjustment).to be_nil
        expect(payment_amounts).to eq [ order.reload.total ]
        expect(order.updater).to have_received(:update)
      end
    end

    context "手数料の無い支払い方法を選んだ" do
      let(:payment_method) { bank_transfer }

      # 注文合計が変わらないので、重い再計算をしない
      it do
        expect(subject).to be true
        expect(fee_adjustment).to be_nil
        expect(payment_amounts).to eq [ order.reload.total ]
        expect(order.updater).not_to have_received(:update)
      end
    end
  end
end
