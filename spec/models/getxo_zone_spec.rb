# frozen_string_literal: true

require "rails_helper"

describe GetxoZone do
  subject { zone }

  let(:zone) { build(:getxo_zone, street:, numbers_constraint:, numbers_range:, organization:) }
  let(:street) { create(:getxo_street) }
  let(:numbers_constraint) { "all_numbers" }
  let(:numbers_range) { "2-4" }
  let(:organization) { create(:organization) }

  describe "validations" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  describe "when no organization" do
    let(:organization) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  describe "when no street" do
    let(:street) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  describe "when no numbers_constraint" do
    let(:numbers_constraint) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  describe "when no numbers_range" do
    let(:numbers_range) { nil }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  describe "when invalid regexp" do
    let(:numbers_range) { " 12,13" }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  describe "when combination exists" do
    let!(:existing) { create(:getxo_zone, street:, numbers_constraint:, numbers_range:, organization:) }

    it "is invalid" do
      expect(subject).to be_invalid
    end

    context "and different organization" do
      let!(:existing) { create(:getxo_zone, street:, numbers_constraint:, numbers_range:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "and different number_range" do
      let!(:existing) { create(:getxo_zone, street:, numbers_constraint:, numbers_range: "1-3", organization:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "and different numbers_constraint" do
      let!(:existing) { create(:getxo_zone, street:, numbers_constraint: "odd_numbers", numbers_range:, organization:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "and different street" do
      let!(:existing) { create(:getxo_zone, numbers_constraint:, numbers_range:, organization:) }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
