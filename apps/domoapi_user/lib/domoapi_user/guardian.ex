defmodule DomoapiUser.Guardian do
  use Guardian, otp_app: :domoapi_user
  alias Domoapi.People
  alias Domoapi.People.Tenant
  require Logger

  def subject_for_token(resource, _claims) do
    Logger.info("subject_for_token")
    {:ok, resource.id}
  end

  def resource_from_claims(claims) do
    Logger.info("resource_from_claims")
    tenant = People.get_tenant_auth(claims["sub"])
    if is_nil(tenant) do
      {:error, :unauthorized}
    else
      {:ok, tenant}
    end
  end
end