require 'spec_helper'

describe Spree::LineItem do

  let(:product) { create(:product, add_ons: [create(:add_on), create(:add_on, sku: 'DEF-123')]) }
  let(:line_item) { create(:line_item, variant: create(:variant, product: product)) }
  let(:other_add_on) { create(:other_add_on) }

  context "callbacks" do
    it { expect(line_item).to callback(:persist_add_on_total).after(:save) }
  end

  it "only allows valid add ons" do
    line_item.add_ons = [other_add_on]
    expect{ line_item.save! }.to raise_error
  end

  context "no current addons" do
    it "should 'create' the add on adjustments" do
      # TODO more robust test
      line_item.add_ons = product.add_ons
      expect(line_item.adjustments.add_ons.count).to eql 2
    end

    it "calculates the discounted amount" do
      line_item.add_ons = product.add_ons
      expect(line_item.discounted_amount).to eql 30.00
    end

    it "correctly updates the price" do
      line_item.quantity = 3
      line_item.add_ons = product.add_ons
      line_item.save!
      expect(line_item.reload.discounted_amount).to eql 50.00
    end

    it "retrieves the add ons" do
      line_item.add_ons = product.add_ons
      expect(line_item.add_ons.map(&:id) - product.add_ons.map(&:id)).to be_empty
    end
  end

  context "with current addons" do
    it "does not duplicate adjusmtents" do
      line_item.add_ons = [product.add_ons, product.add_ons]
      expect(line_item.adjustments.count).to eq 2
      expect(line_item.add_ons.map(&:id) - product.add_ons.map(&:id)).to be_empty
    end
  end

  describe "when add on is deleted" do
    before do
      line_item.add_ons = product.add_ons
    end

    it "should preseve the association" do
      product.add_ons.first.destroy
      expect(line_item.add_ons).to eq product.add_ons
    end

    it "should mark the line_itam invalid" do
      product.add_ons.first.destroy
      expect(line_item.reload.invalid?).to be true
    end

  end

end
