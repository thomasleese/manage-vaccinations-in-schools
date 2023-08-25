class ConsentForms::NameController < ConsentForms::BaseController
  before_action :set_session, only: %i[edit update]
  before_action :set_consent_form, only: %i[edit update]

  layout "two_thirds"

  def update
    @consent_form.assign_attributes(update_params)
    if @consent_form.save(context: :edit_name)
      redirect_to edit_session_consent_form_date_of_birth_path(
                    @session,
                    @consent_form
                  )
    else
      render action: :edit
    end
  end

  def edit
  end

  private

  def set_consent_form
    @consent_form = ConsentForm.find(params.fetch(:consent_form_id))
  end

  def set_session
    @session = Session.find(params.fetch(:session_id) { params.fetch(:id) })
  end

  def update_params
    params.fetch(:consent_form, {}).permit(
      %i[first_name last_name use_common_name common_name]
    )
  end
end