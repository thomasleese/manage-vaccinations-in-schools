require "rails_helper"

RSpec.describe "Self-consent" do
  after { Timecop.return }

  scenario "No consent from parent, the child is Gillick competent so can self-consent" do
    given_an_hpv_campaign_is_underway
    and_it_is_the_day_of_a_vaccination_session
    and_there_is_a_child_without_parental_consent

    when_the_nurse_carries_out_a_gillick_competence_assessment_and_records_it
    then_the_child_can_give_their_own_consent_that_the_nurse_records

    when_the_nurse_views_the_childs_record
    then_they_see_that_the_child_has_consent
    and_the_child_should_be_safe_to_vaccinate
  end

  def given_an_hpv_campaign_is_underway
    @team = create(:team, :with_one_nurse)
    campaign = create(:campaign, :hpv, team: @team)
    location = create(:location, name: "Pilot School", team: @team)
    @session =
      create(:session, :in_future, campaign:, location:, patients_in_session: 1)
    @child = @session.patients.first
  end

  def and_it_is_the_day_of_a_vaccination_session
    Timecop.freeze(@session.date)
  end

  def and_there_is_a_child_without_parental_consent
    sign_in @team.users.first

    visit "/dashboard"

    click_on "Campaigns", match: :first
    click_on "HPV"
    click_on "Pilot School"
    click_on "Check consent responses"

    expect(page).to have_content("No consent ( 1 )")
    expect(page).to have_content(@child.full_name)
  end

  def when_the_nurse_carries_out_a_gillick_competence_assessment_and_records_it
    click_on @child.full_name

    click_on "Assess Gillick competence"
    click_on "Give your assessment"

    choose "Yes, they are Gillick competent"

    fill_in "Give details of your assessment",
            with: "They understand the benefits and risks of the vaccine"
    click_on "Continue"
  end

  def then_the_child_can_give_their_own_consent_that_the_nurse_records
    # record consent
    choose "Yes, they agree"
    click_on "Continue"

    # answer the health questions
    all("label", text: "No").each(&:click)
    choose "Yes, it’s safe to vaccinate"
    click_on "Continue"

    # confirmation page
    click_on "Confirm"

    expect(page).to have_content("Check consent responses")
    expect(page).to have_content("Given ( 1 )")
  end

  def when_the_nurse_views_the_childs_record
    click_on "View child record"
  end

  def then_they_see_that_the_child_has_consent
    expect(page).to have_content(
      "#{@child.full_name} Child (Gillick competent)"
    )
    expect(page).to have_content("Consent given")
  end

  def and_the_child_should_be_safe_to_vaccinate
    expect(page).to have_content("Safe to vaccinate")
  end
end