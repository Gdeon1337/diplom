defmodule DomoapiWeb.Settings.CompanyController do
  use DomoapiWeb, :controller

  alias Domoapi.Users
  alias Domoapi.Users.Company

  action_fallback DomoapiWeb.FallbackController

  def index(conn, params) do
    companies = Users.list_companies(params)
    json(conn, %{
      company: companies.entries,
      page_number: companies.page_number,
      page_size: companies.page_size,
      total_pages: companies.total_pages,
      total_entries: companies.total_entries
      })
  end

  def create(conn, company_params) do
    with {:ok, %Company{} = company} <- Users.create_company(company_params) do
      conn
      |> put_status(:created)
      |> json(company)
    end
  end

  def show(conn, %{"id" => id}) do
    company = Users.get_company!(id)
    json(conn,company)
  end

  def update(conn, %{"id" => id, "company" => company_params}) do
    company = Users.get_company!(id)

    with {:ok, %Company{} = company} <- Users.update_company(company, company_params) do
      json(conn, company)
    end
  end

  def delete(conn, %{"id" => id}) do
    company = Users.get_company!(id)

    with {:ok, %Company{}} <- Users.delete_company(company) do
      send_resp(conn, :no_content, "")
    end
  end
end
