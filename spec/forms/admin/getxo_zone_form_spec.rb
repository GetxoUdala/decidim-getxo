# frozen_string_literal: true

require "rails_helper"

module Decidim
  module Admin
    describe GetxoZoneForm do
      subject { form }

      let(:street_id) { 123 }
      let(:numbers_constraint) { "odd_numbers" }
      let(:numbers_range) { "2-3" }
      let(:params) do
        {
          street_id: street_id,
          numbers_constraint: numbers_constraint,
          numbers_range: numbers_range
        }
      end
      let(:organization) { create :organization }
      let(:form) do
        described_class.from_params(params).with_context(current_organization: organization)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when no street" do
        let(:street_id) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no numbers_constraint" do
        let(:numbers_constraint) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no numbers_range" do
        let(:numbers_range) { nil }

        it { is_expected.to be_valid }
      end

      context "when range is a single number" do
        let(:numbers_range) { "1" }

        it { is_expected.to be_valid }
      end

      context "when range is a short list" do
        let(:numbers_range) { "1,5" }

        it { is_expected.to be_valid }
      end

      context "when range is a list" do
        let(:numbers_range) { "1,3,5" }

        it { is_expected.to be_valid }
      end

      context "when range has trim spaces" do
        let(:numbers_range) { " 1,3,5 " }

        it { is_expected.to be_invalid }
      end

      context "when range is a mix" do
        let(:numbers_range) { "1,3,5 1-2" }

        it { is_expected.to be_invalid }
      end

      context "when range has more than one hyphen" do
        let(:numbers_range) { "3-5 1-2" }

        it { is_expected.to be_invalid }
      end

      context "when range has more than one hyphen without spaces" do
        let(:numbers_range) { "3-5-10" }

        it { is_expected.to be_invalid }
      end

      context "when range has more than double hyphen" do
        let(:numbers_range) { "3--6" }

        it { is_expected.to be_invalid }
      end

      context "when range has spaces in between" do
        let(:numbers_range) { "3,5 1,2" }

        it { is_expected.to be_invalid }
      end

      context "when range is single number" do
        let(:numbers_range) { "123" }

        it { is_expected.to be_valid }
      end

      context "when range has other chars" do
        let(:numbers_range) { "123a" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
