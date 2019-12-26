defmodule DomoapiWeb.CompanyRolesView do
  use DomoapiWeb, :view
  alias DomoapiWeb.CompanyRolesView

  def render("index.json", %{company_roles: company_roles}) do
    %{data: render_many(company_roles, CompanyRolesView, "company_roles.json")}
  end

  def render("show.json", %{company_roles: company_roles}) do
    %{data: render_one(company_roles, CompanyRolesView, "company_roles.json")}
  end

  def render("company_roles.json", %{company_roles: company_roles}) do
    %{id: company_roles.id}
  end
end
