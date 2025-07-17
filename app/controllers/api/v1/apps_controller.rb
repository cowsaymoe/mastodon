# frozen_string_literal: true

class Api::V1::AppsController < Api::BaseController
  skip_before_action :require_authenticated_user!

  def create
    @app = Doorkeeper::Application.create!(application_options)
    render json: @app, serializer: REST::CredentialApplicationSerializer
  end

  private

  def application_options
    {
      name: app_params[:client_name],
      redirect_uri: app_params[:redirect_uris],
      scopes: app_scopes_or_default,
      website: app_params[:website],
    }
  end

  def app_scopes_or_default
    requested = app_params[:scopes]
    return Doorkeeper.configuration.default_scopes unless requested.present?
    allowed = Doorkeeper.configuration.scopes
    valid = requested.split(' ')
    filtered = valid.select { |s| allowed.exists?(s) }
    filtered.any? ? filtered.join(' ') : Doorkeeper.configuration.default_scopes
  end

  def app_params
    params.permit(:client_name, :scopes, :website, :redirect_uris, redirect_uris: [])
  end
end
