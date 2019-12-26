defmodule Domoapi.Place.ApartmentSetting do
  use Domoapi.Schema
  alias Domoapi.Place.Apartment
  alias Domoapi.Users.Company
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :clean, :enabled, :min_threshold, :max_threshold, :codec_rx_vol, :codec_tx_vol, :codec_internet_tx_vol, :codec_internet_rx_vol, :codec_agc_tx_enable, :codec_agc_tx_target_level, :codec_agc_tx_max_gain, :codec_agc_rx_enable, :codec_agc_rx_target_level, :codec_agc_rx_max_gain, :codec_agc_internet_tx_enable, :codec_agc_internet_tx_target_level, :codec_agc_internet_tx_max_gain, :codec_agc_internet_rx_enabled, :codec_agc_internet_rx_target_level, :codec_agc_internet_rx_max_gain, :apartment_id]}
  schema "apartment_settings" do
    field :clean, :boolean
    field :enabled, :boolean
    field :min_threshold, :integer
    field :max_threshold, :integer

    field :codec_rx_vol, :integer
    field :codec_tx_vol, :integer

    field :codec_internet_tx_vol, :integer
    field :codec_internet_rx_vol, :integer

    field :codec_agc_tx_enable, :boolean
    field :codec_agc_tx_target_level, :integer
    field :codec_agc_tx_max_gain, :integer
    field :codec_agc_rx_enable, :boolean
    field :codec_agc_rx_target_level, :integer
    field :codec_agc_rx_max_gain, :integer

    field :codec_agc_internet_tx_enable, :boolean
    field :codec_agc_internet_tx_target_level, :integer
    field :codec_agc_internet_tx_max_gain, :integer
    field :codec_agc_internet_rx_enabled, :boolean
    field :codec_agc_internet_rx_target_level, :integer
    field :codec_agc_internet_rx_max_gain, :integer
    field :deleted, :boolean, default: false
    belongs_to :apartment, Apartment
    timestamps()
  end

  @doc false
  def changeset(apartment_setting, attrs) do
    apartment_setting
    |> cast(attrs, [:clean, :enabled, :min_threshold, :max_threshold, :codec_rx_vol, :codec_tx_vol, :codec_internet_tx_vol, :codec_internet_rx_vol, :codec_agc_tx_enable, :codec_agc_tx_target_level, :codec_agc_tx_max_gain, :codec_agc_rx_enable, :codec_agc_rx_target_level, :codec_agc_rx_max_gain, :codec_agc_internet_tx_enable, :codec_agc_internet_tx_target_level, :codec_agc_internet_tx_max_gain, :codec_agc_internet_rx_enabled, :codec_agc_internet_rx_target_level, :codec_agc_internet_rx_max_gain, :apartment_id, :deleted])
    |> validate_required([:apartment_id])
  end
end
