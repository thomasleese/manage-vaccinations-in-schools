class SessionsController < ApplicationController
  before_action :set_session, except: %i[index create]
  before_action :set_school, only: %i[show]

  layout "two_thirds", except: %i[index show]

  def create
    skip_policy_scope

    campaign = current_user.team.campaigns.first

    @session = Session.create!(draft: true, campaign:)

    redirect_to session_edit_path(@session, :location)
  end

  def index
    @sessions_by_type =
      policy_scope(Session).active.in_progress.group_by(&:type)
  end

  def show
    @patient_sessions =
      @session.patient_sessions.strict_loading.includes(
        :campaign,
        :consents,
        :triage,
        :vaccination_records
      )

    @counts =
      SessionStats.new(patient_sessions: @patient_sessions, session: @session)
  end

  def edit
  end

  def make_in_progress
    @session.update!(date: Time.zone.today)
    redirect_to session_path,
                flash: {
                  success: {
                    heading: "Session is now in progress"
                  }
                }
  end

  private

  def set_session
    @session = policy_scope(Session).find(params[:id])
  end

  def set_school
    @school = @session.location
  end
end
