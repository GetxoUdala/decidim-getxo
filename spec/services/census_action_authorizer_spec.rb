# frozen_string_literal: true

require "rails_helper"

describe CensusActionAuthorizer do
  subject { authorizer }

  let(:organization) { create(:organization, available_authorizations: [name]) }
  let(:name) { "census_authorization_handler" }
  let(:user) { create(:user, organization:) }
  let(:authorizer) { described_class.new(authorization, options, nil, nil) }
  let(:response) { subject.authorize }

  let!(:authorization) do
    create(:authorization, :granted, name:, metadata:, user:)
  end

  let(:metadata) do
    {
      "street" => street_name,
      "street_number" => street_number
    }
  end
  let(:options) do
    { "zones" => zones }
  end
  let(:zones) { zone.id.to_s }
  let(:street_name) { street.name }
  let(:street_number) { 3 }
  let(:street) { create(:getxo_street, organization:) }
  let(:zone) { create(:getxo_zone, street:, numbers_constraint:, numbers_range:, organization:) }
  let(:numbers_constraint) { "all_numbers" }
  let(:numbers_range) { "1-4" }
  let(:zone2) { create(:getxo_zone, organization:) }

  shared_examples "ok" do
    it "returns ok" do
      expect(response).to include(:ok)
    end
  end

  shared_examples "unauthorized" do
    it "returns unauthorized" do
      expect(response).to include(:unauthorized)
    end
  end

  it_behaves_like "ok"

  context "when no authorization" do
    let(:authorization) { nil }

    it "returns missing" do
      expect(response).to include(:missing)
    end
  end

  context "when no zones specified" do
    let(:zones) { " " }

    it_behaves_like "ok"
  end

  context "when no street" do
    let(:street_name) { nil }

    it_behaves_like "unauthorized"
  end

  context "when no street_number" do
    let(:street_number) { nil }

    it_behaves_like "unauthorized"
  end

  context "when even number" do
    let(:numbers_constraint) { "even_numbers" }

    it_behaves_like "unauthorized"

    context "and number is even" do
      let(:street_number) { 2 }

      it_behaves_like "ok"
    end
  end

  context "when odd number" do
    let(:numbers_constraint) { "odd_numbers" }

    it_behaves_like "ok"

    context "and number is even" do
      let(:street_number) { 2 }

      it_behaves_like "unauthorized"
    end
  end

  context "when number is not in the interval" do
    let(:street_number) { 10 }

    it_behaves_like "unauthorized"
  end

  context "when range is a list" do
    let(:numbers_range) { "1,2,3,4" }

    it_behaves_like "ok"

    context "and number is not in the interval" do
      let(:street_number) { 10 }

      it_behaves_like "unauthorized"
    end
  end
end
