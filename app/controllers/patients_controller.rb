class PatientsController < ApplicationController
  before_action :set_patient_session
  before_action :set_session
  before_action :set_patient
  before_action :set_draft_vaccination_record
  before_action :set_section_and_tab
  before_action :set_back_link

  layout "two_thirds", except: :index

  def show
  end

  private

  def set_patient_session
    @patient_session =
      policy_scope(PatientSession)
        .includes(:patient, :session, :triage, :vaccination_records)
        .preload(:consents)
        .find_by!(
          session_id: params.fetch(:session_id),
          patient_id: params.fetch(:id)
        )
  end

  def set_session
    @session = @patient_session.session
  end

  def set_patient
    @patient = @patient_session.patient
  end

  def set_draft_vaccination_record
    @draft_vaccination_record =
      @patient.draft_vaccination_records_for_session(
        @session
      ).find_or_initialize_by(recorded_at: nil)
  end

  def set_section_and_tab
    @section = params[:section]
    @tab = params[:tab]
  end

  def set_back_link
    @back_link =
      session_section_tab_path @session,
                               section: params[:section],
                               tab: params[:tab]
  end
end