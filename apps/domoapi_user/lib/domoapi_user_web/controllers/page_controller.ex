defmodule DomoapiUserWeb.PageController do
  use DomoapiUserWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
