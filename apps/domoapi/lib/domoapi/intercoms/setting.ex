defmodule Domoapi.Intercoms.Setting do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :min_threshold, :max_threshold, :codec_rx_vol, :codec_tx_vol, :codec_beep_vol, :codec_internet_tx_vol, :codec_internet_rx_vol, :codec_internet_tx_beep_vol, :codec_internet_beep_vol, :codec_agc_tx_enable, :codec_agc_tx_target_level, :codec_agc_tx_max_gain, :codec_agc_rx_enable, :codec_agc_rx_target_level, :codec_agc_rx_max_gain, :codec_agc_internet_tx_enable, :codec_agc_internet_tx_target_level,  :codec_agc_internet_tx_max_gain,  :codec_agc_internet_rx_enabled, :codec_agc_internet_rx_target_level, :codec_agc_internet_rx_max_gain, :max_ring_duration_ms, :max_call_duration_ms, :door_open_time_ms, :first_room_number, :intercom_id]}
  schema "settings" do
    field :min_threshold, :integer
    field :max_threshold, :integer

    field :codec_rx_vol, :integer
    field :codec_tx_vol, :integer
    field :codec_beep_vol, :integer

    field :codec_internet_tx_vol, :integer
    field :codec_internet_rx_vol, :integer
    field :codec_internet_tx_beep_vol, :integer
    field :codec_internet_beep_vol, :integer

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


    field :max_ring_duration_ms, :integer
    field :max_call_duration_ms, :integer
    field :door_open_time_ms, :integer
    field :first_room_number, :integer
    field :deleted, :boolean, default: false
    belongs_to :intercom, Intercom
    timestamps()
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:deleted, :max_ring_duration_ms, :max_call_duration_ms, :door_open_time_ms, :first_room_number,  :intercom_id, :min_threshold, :max_threshold, :codec_rx_vol, :codec_tx_vol, :codec_beep_vol, :codec_internet_tx_vol, :codec_internet_rx_vol, :codec_internet_tx_beep_vol, :codec_internet_beep_vol, :codec_agc_tx_enable, :codec_agc_tx_target_level, :codec_agc_tx_max_gain, :codec_agc_rx_enable, :codec_agc_rx_target_level, :codec_agc_rx_max_gain, :codec_agc_internet_tx_enable, :codec_agc_internet_tx_target_level, :codec_agc_internet_tx_max_gain, :codec_agc_internet_rx_enable, :codec_agc_internet_rx_target_level, :apartment_id, :codec_agc_internet_rx_max_gain])
    |> validate_required([:first_room_number,  :intercom_id])
  end
end
