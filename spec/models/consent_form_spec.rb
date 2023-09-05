require "rails_helper"

RSpec.describe ConsentForm, type: :model do
  describe "Validations" do
    let(:form_step) { nil }
    let(:use_common_name) { false }
    subject { build(:consent_form, form_step:, use_common_name:) }

    it "validates all fields when no form_step is set" do
      expect(subject).to validate_presence_of(:first_name).on(:update)
      expect(subject).to validate_presence_of(:last_name).on(:update)
      expect(subject).to validate_presence_of(:date_of_birth).on(:update)
    end

    context "when form_step is :name" do
      let(:form_step) { :name }

      it { should validate_presence_of(:first_name).on(:update) }
      it { should validate_presence_of(:last_name).on(:update) }

      context "when use_common_name is true" do
        let(:use_common_name) { true }

        it { should validate_presence_of(:common_name).on(:update) }
      end
    end

    context "when form_step is :date_of_birth" do
      let(:form_step) { :date_of_birth }

      context "runs validations from previous steps" do
        it { should validate_presence_of(:first_name).on(:update) }
      end

      it { should validate_presence_of(:date_of_birth).on(:update) }
      # it { should validate_comparison_of(:date_of_birth)
      #       .is_less_than(Time.zone.today)
      #       .is_greater_than_or_equal_to(22.years.ago.to_date)
      #       .is_less_than_or_equal_to(3.years.ago.to_date)
      #       .on(:update) }
    end

    context "when form_step is :school" do
      let(:form_step) { :school }

      context "runs validations from previous steps" do
        it { should validate_presence_of(:first_name).on(:update) }
        it { should validate_presence_of(:date_of_birth).on(:update) }
      end

      it { should validate_presence_of(:is_this_their_school).on(:update) }
      it do
        should validate_inclusion_of(:is_this_their_school).in_array(
                 %w[yes no]
               ).on(:update)
      end
    end
  end

  describe "#full_name" do
    it "returns the full name as a string" do
      consent_form = build(:consent_form, first_name: "John", last_name: "Doe")
      expect(consent_form.full_name).to eq("John Doe")
    end
  end
end