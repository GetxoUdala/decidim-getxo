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
      "street_number" => street_number,
      "date_of_birth" => date_of_birth
    }
  end
  let(:options) do
    { "zones" => zones, "minimum_age" => minimum_age, "maximum_age" => maximum_age }
  end
  let(:zones) { zone.id.to_s }
  let(:date_of_birth) { 30.years.ago.strftime("%Y-%m-%d") }
  let(:minimum_age) { 0 }
  let(:maximum_age) { 0 }
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

  context "with age restrictions" do
    let(:zones) { " " }

    context "when no age limits are set" do
      let(:minimum_age) { 0 }
      let(:maximum_age) { 0 }

      it_behaves_like "ok"
    end

    context "when minimum_age is set" do
      let(:minimum_age) { 18 }

      context "and user is older than minimum" do
        let(:date_of_birth) { 30.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "ok"
      end

      context "and user is exactly minimum age" do
        let(:date_of_birth) { 18.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "ok"
      end

      context "and user is younger than minimum" do
        let(:date_of_birth) { 16.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "unauthorized"
      end
    end

    context "when maximum_age is set" do
      let(:maximum_age) { 65 }

      context "and user is younger than maximum" do
        let(:date_of_birth) { 40.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "ok"
      end

      context "and user is exactly maximum age" do
        let(:date_of_birth) { 65.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "ok"
      end

      context "and user is older than maximum" do
        let(:date_of_birth) { 70.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "unauthorized"
      end
    end

    context "when both minimum and maximum are set" do
      let(:minimum_age) { 18 }
      let(:maximum_age) { 65 }

      context "and user is within range" do
        let(:date_of_birth) { 30.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "ok"
      end

      context "and user is below minimum" do
        let(:date_of_birth) { 16.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "unauthorized"
      end

      context "and user is above maximum" do
        let(:date_of_birth) { 70.years.ago.strftime("%Y-%m-%d") }

        it_behaves_like "unauthorized"
      end
    end

    context "when limits are negative" do
      let(:minimum_age) { -5 }
      let(:maximum_age) { -1 }

      it_behaves_like "ok"
    end

    context "when date_of_birth is missing and limits are set" do
      let(:minimum_age) { 18 }
      let(:date_of_birth) { nil }

      it_behaves_like "ok"
    end

    context "when date_of_birth is invalid and limits are set" do
      let(:minimum_age) { 18 }
      let(:date_of_birth) { "not-a-date" }

      it_behaves_like "ok"
    end

    context "when user turns the minimum age tomorrow" do
      let(:minimum_age) { 18 }
      let(:date_of_birth) { (18.years.ago + 1.day).strftime("%Y-%m-%d") }

      it_behaves_like "unauthorized"
    end
  end
end
