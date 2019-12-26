defmodule Domoapi.Repo.Migrations.CreateApartmentSettings do
  use Ecto.Migration

  def change do
    create table(:apartment_settings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :clean, :boolean
      add :enabled, :boolean
      add :min_threshold, :integer
      add :max_threshold, :integer

      add :codec_rx_vol, :integer
      add :codec_tx_vol, :integer
      
      add :codec_internet_tx_vol, :integer
      add :codec_internet_rx_vol, :integer

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
      add :deleted, :boolean, default: false
      add :apartment_id, references(:apartments, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:apartment_settings, [:apartment_id])  

  end
end
