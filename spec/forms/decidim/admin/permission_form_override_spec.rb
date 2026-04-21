# frozen_string_literal: true

require "rails_helper"

describe Decidim::Admin::PermissionForm do
  subject(:form) do
    described_class.new(
      authorization_handlers: selected_handlers,
      authorization_handlers_options: handlers_options
    )
  end

  let(:selected_handlers) { ["census_authorization_handler"] }
  let(:handlers_options) do
    { "census_authorization_handler" => { "minimum_age" => minimum_age, "maximum_age" => maximum_age } }
  end
  let(:minimum_age) { 18 }
  let(:maximum_age) { 65 }

  describe "validity by minimum_age input" do
    [
      { value: 0, valid: true, note: "zero (default)" },
      { value: 18, valid: true, note: "positive integer within range" },
      { value: -1, valid: false, note: "negative integer" },
      { value: -999, valid: false, note: "large negative integer" },
      { value: nil, valid: true, note: "nil" },
      { value: "", valid: true, note: "empty string (blank)" },
      { value: "18", valid: true, note: "numeric string" },
      { value: "-7", valid: false, note: "negative numeric string" }
    ].each do |row|
      context "when minimum_age = #{row[:value].inspect} (#{row[:note]})" do
        let(:minimum_age) { row[:value] }

        if row[:valid]
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe "validity by maximum_age input" do
    [
      { value: 0, valid: true },
      { value: 65, valid: true },
      { value: -1, valid: false },
      { value: nil, valid: true },
      { value: "", valid: true },
      { value: "-5", valid: false }
    ].each do |row|
      context "when maximum_age = #{row[:value].inspect}" do
        let(:maximum_age) { row[:value] }

        if row[:valid]
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe "error reporting" do
    context "when minimum_age is negative" do
      let(:minimum_age) { -1 }

      it "adds a :base error mentioning the field label" do
        form.valid?
        expect(form.errors[:base].join).to match(/Minimum age/i)
      end
    end

    context "when maximum_age is negative" do
      let(:maximum_age) { -5 }

      it "adds a :base error mentioning the field label" do
        form.valid?
        expect(form.errors[:base].join).to match(/Maximum age/i)
      end
    end

    context "when both values are invalid" do
      let(:minimum_age) { -1 }
      let(:maximum_age) { -5 }

      it "reports both fields" do
        form.valid?
        messages = form.errors[:base].join
        expect(messages).to match(/Minimum age/i)
        expect(messages).to match(/Maximum age/i)
      end
    end
  end

  describe "cross-field range consistency" do
    context "when maximum_age is less than minimum_age" do
      let(:minimum_age) { 65 }
      let(:maximum_age) { 18 }

      it { is_expected.not_to be_valid }

      it "reports the inconsistency" do
        form.valid?
        expect(form.errors[:base].join).to match(/Maximum age/i)
      end
    end

    context "when maximum_age equals minimum_age" do
      let(:minimum_age) { 18 }
      let(:maximum_age) { 18 }

      it { is_expected.to be_valid }
    end

    context "when minimum_age is 0 and maximum_age is less than minimum (still zero treated as not set)" do
      let(:minimum_age) { 0 }
      let(:maximum_age) { 0 }

      it { is_expected.to be_valid }
    end

    context "when only minimum_age is set" do
      let(:minimum_age) { 18 }
      let(:maximum_age) { 0 }

      it { is_expected.to be_valid }
    end

    context "when only maximum_age is set" do
      let(:minimum_age) { 0 }
      let(:maximum_age) { 65 }

      it { is_expected.to be_valid }
    end
  end

  describe "skipped cases (no validation should fire)" do
    context "when no handlers are selected" do
      let(:selected_handlers) { [] }
      let(:minimum_age) { -10 }

      it { is_expected.to be_valid }
    end

    context "when handler list contains a blank entry (Rails hidden-field artefact)" do
      let(:selected_handlers) { ["", "census_authorization_handler"] }

      it "skips the blank entry without crashing" do
        expect { form.valid? }.not_to raise_error
      end
    end

    context "when handler name is unknown" do
      let(:selected_handlers) { ["unknown_handler"] }
      let(:handlers_options) { { "unknown_handler" => { "foo" => "bar" } } }

      it "skips unknown handlers without crashing" do
        expect { form.valid? }.not_to raise_error
      end
    end
  end

  describe "census_authorization_handler options schema coercion contract" do
    let(:schema_class) do
      Decidim::Verifications.find_workflow_manifest(:census_authorization_handler).options.schema
    end

    # Documents the exact behaviour of Rails' `type: :integer` coercion for every
    # kind of input an admin might submit. Only numericality runs server-side —
    # raw non-integer rejection is handled client-side via `data-pattern` on the
    # number inputs, matching how Decidim itself validates option attributes.
    [
      { input: 0, coerced: 0, valid: true, note: "zero (Integer)" },
      { input: 18, coerced: 18, valid: true, note: "positive Integer" },
      { input: 999, coerced: 999, valid: true, note: "large positive Integer" },
      { input: -1, coerced: -1, valid: false, note: "negative Integer → numericality fails" },
      { input: -999, coerced: -999, valid: false, note: "large negative Integer → numericality fails" },
      { input: "42", coerced: 42, valid: true, note: "positive numeric string" },
      { input: "-7", coerced: -7, valid: false, note: "negative numeric string → numericality fails" },
      { input: "3.5", coerced: 3, valid: true, note: "positive float string → coerced to 3, accepted" },
      { input: "-2.9", coerced: -2, valid: false, note: "negative float string → coerced to -2, fails" },
      { input: "-0.5", coerced: 0, valid: true, note: "near-zero negative float string → coerced to 0" },
      { input: 3.7, coerced: 3, valid: true, note: "positive Float → coerced to 3" },
      { input: -1.5, coerced: -1, valid: false, note: "negative Float → coerced to -1, fails" },
      { input: "abc", coerced: 0, valid: true, note: "non-numeric text → coerced to 0 (ignored)" },
      { input: "18abc", coerced: 18, valid: true, note: "numeric prefix + text → coerced to 18" },
      { input: "", coerced: nil, valid: true, note: "empty string → blank → skipped" },
      { input: nil, coerced: nil, valid: true, note: "nil → blank → skipped" }
    ].each do |row|
      it "treats #{row[:input].inspect} as #{row[:coerced].inspect} and is #{row[:valid] ? "valid" : "invalid"} (#{row[:note]})" do
        instance = schema_class.new(minimum_age: row[:input])
        expect(instance.minimum_age).to eq(row[:coerced])
        expect(instance.valid?).to eq(row[:valid])
      end
    end

    it "reports numericality error key when value is negative" do
      instance = schema_class.new(minimum_age: -1)
      instance.valid?
      expect(instance.errors[:minimum_age]).to include(a_string_matching(/greater than or equal to 0/))
    end
  end
end
