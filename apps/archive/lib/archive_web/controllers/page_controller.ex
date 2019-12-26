defmodule ArchiveWeb.PageController do
  use ArchiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
