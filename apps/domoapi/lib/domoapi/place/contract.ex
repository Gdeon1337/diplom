defmodule Domoapi.Place.Contract do
  use Domoapi.Schema
  alias Domoapi.Users.Company
  alias Domoapi.People.Tenant
  alias Domoapi.Place.Apartment
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :number_contracts, :intercom_service, :video_service, :recognition_service, :docs, :datetime_video, :datetime_intercom, :datetime_recognition, :datetime_contract, :company_id, :tenant_id, :apartment_id]}
  schema "contracts" do
    field :number_contracts, :integer
    field :intercom_service, :boolean, default: false
    field :video_service, :boolean, default: false
    field :recognition_service, :boolean, default: false
    field :docs, :binary
    field :datetime_video, :naive_datetime
    field :datetime_intercom, :naive_datetime
    field :datetime_recognition, :naive_datetime
    field :datetime_contract, :naive_datetime

    field :deleted, :boolean, default: false

    belongs_to :company, Company
    belongs_to :apartment, Apartment
    belongs_to :tenant, Tenant
    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:number_contracts, :intercom_service, :video_service, :recognition_service, :docs, :datetime_video, :datetime_intercom, :datetime_recognition, :datetime_contract, :company_id, :tenant_id, :apartment_id, :deleted])
    |> validate_required([:number_contracts, :intercom_service, :video_service, :recognition_service, :datetime_video, :datetime_intercom, :datetime_recognition, :datetime_contract, :company_id])
    |> convert_date_time
  end

  def convert_date_time(%Ecto.Changeset{valid?: true, changes: %{datetime_video: datetime_video, datetime_intercom: datetime_intercom, datetime_recognition: datetime_recognition, datetime_contract: datetime_contract}} = changeset) do
    datetime_video = datetime_video
      |> DateTime.to_naive
    datetime_intercom = datetime_intercom
      |> DateTime.to_naive
    datetime_recognition = datetime_recognition
      |> DateTime.to_naive
    datetime_contract = datetime_contract
      |> DateTime.to_naive
    changeset
     |> put_change(:datetime_video, datetime_video)
     |> put_change(:datetime_intercom, datetime_intercom)
     |> put_change(:datetime_recognition, datetime_recognition)
     |> put_change(:datetime_contract, datetime_contract)
  end

  def convert_date_time(changeset) do
    changeset
  end


end
