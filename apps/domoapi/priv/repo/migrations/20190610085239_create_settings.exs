defmodule Domoapi.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :min_threshold, :integer
      add :max_threshold, :integer
  
      add :codec_rx_vol, :integer
      add :codec_tx_vol, :integer
      add :codec_beep_vol, :integer
  
      add :codec_internet_tx_vol, :integer
      add :codec_internet_rx_vol, :integer
      add :codec_internet_tx_beep_vol, :integer
      add :codec_internet_beep_vol, :integer
  
      add :codec_agc_tx_enable, :boolean
      add :codec_agc_tx_target_level, :integer
      add :codec_agc_tx_max_gain, :integer
      add :codec_agc_rx_enable, :boolean
      add :codec_agc_rx_target_level, :integer
      add :codec_agc_rx_max_gain, :integer
  
      add :codec_agc_internet_tx_enable, :boolean
      add :codec_agc_internet_tx_target_level, :integer
      add :codec_agc_internet_tx_max_gain, :integer
      add :codec_agc_internet_rx_enabled, :boolean
      add :codec_agc_internet_rx_target_level, :integer
      add :codec_agc_internet_rx_max_gain, :integer
  
  
      add :max_ring_duration_ms, :integer
      add :max_call_duration_ms, :integer
      add :door_open_time_ms, :integer
      add :first_room_number, :integer
      add :intercom_id, references(:intercoms, on_delete: :nothing, type: :uuid)
      add :deleted, :boolean

      timestamps()
    end

    create index(:settings, [:intercom_id])    
  end
end
