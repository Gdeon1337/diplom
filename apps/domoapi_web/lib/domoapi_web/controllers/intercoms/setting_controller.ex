defmodule DomoapiWeb.SettingController do
  use DomoapiWeb, :controller
  use PhoenixSwagger

  alias Domoapi.Intercoms
  alias Domoapi.Intercoms.Setting
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      OutputSettings:
        swagger_schema do
          title("output settings")
          properties do
            id(:string, "Setting ID")
            max_ring_duration_ms(:string, "max_ring_duration_ms")
            max_call_duration_ms(:string, "max_call_duration_ms")
            door_open_time_ms(:string, "door_open_time_ms")
            first_room_number(:string, "first_room_number")
            threshold1(:string, "Нижний порог сигнала линии")
            threshold2(:string, "Верхний порог сигнала линии")

            codec_rx_vol(:string, "Громкость приема речи")
            codec_tx_vol(:string, "Громкость передачи речи")
            codec_beep_vol(:string, "Громкость клавиатуры")

            codec_internet_tx_vol(:string, "Громкость передачи речи во время интернет звонка")
            codec_internet_rx_vol(:string, "Громкость приема речи во время интернет звонка")
            codec_internet_tx_beep_vol(:string, "Громкость передачи тонового сигнала во время интернет звонка")
            codec_internet_beep_vol(:string, "Громкость клавиатуры во время интернет звонка")

            codec_agc_tx_enable(:string, "Включить автоматическую регулировку усиления передаваемой речи")
            codec_agc_tx_target_level(:string, "Желаемый уровень передаваемой речи")
            codec_agc_tx_max_gain(:string, "Максимальный уровень усиления передаваемой речи")
            codec_agc_rx_enable(:string, "Включить автоматическую регулировку усиления принимаемой речи")
            codec_agc_rx_target_level(:string, "Желаемый уровень принимаемой речи")
            codec_agc_rx_max_gain(:string, "Максимальный уровень усиления принимаемой речи")

            codec_agc_internet_tx_enable(:string, "Включить автоматическую регулировку усиления передаваемой речи во время интернет звонка")
            codec_agc_internet_tx_target_level(:string, "Желаемый уровень передаваемой речи")
            codec_agc_internet_tx_max_gain(:string, "Максимальный уровень усиления передаваемой речи")
            codec_agc_internet_rx_enable(:string, "Включить автоматическую регулировку усиления принимаемой речи")
            codec_agc_internet_rx_target_level(:string, "Желаемый уровень принимаемой речи")
            codec_agc_internet_rx_max_gain(:string, "Максимальный уровень усиления принимаемой речи")
            intercom_id(:string, "intercom_id")
        end
      end,
      InputSettings:
        swagger_schema do
          title("input settings")
          properties do
            max_ring_duration_ms(:string, "max_ring_duration_ms")
            max_call_duration_ms(:string, "max_call_duration_ms")
            door_open_time_ms(:string, "door_open_time_ms")
            first_room_number(:string, "first_room_number")
            threshold1(:string, "Нижний порог сигнала линии")
            threshold2(:string, "Верхний порог сигнала линии")

            codec_rx_vol(:string, "Громкость приема речи")
            codec_tx_vol(:string, "Громкость передачи речи")
            codec_beep_vol(:string, "Громкость клавиатуры")

            codec_internet_tx_vol(:string, "Громкость передачи речи во время интернет звонка")
            codec_internet_rx_vol(:string, "Громкость приема речи во время интернет звонка")
            codec_internet_tx_beep_vol(:string, "Громкость передачи тонового сигнала во время интернет звонка")
            codec_internet_beep_vol(:string, "Громкость клавиатуры во время интернет звонка")

            codec_agc_tx_enable(:string, "Включить автоматическую регулировку усиления передаваемой речи")
            codec_agc_tx_target_level(:string, "Желаемый уровень передаваемой речи")
            codec_agc_tx_max_gain(:string, "Максимальный уровень усиления передаваемой речи")
            codec_agc_rx_enable(:string, "Включить автоматическую регулировку усиления принимаемой речи")
            codec_agc_rx_target_level(:string, "Желаемый уровень принимаемой речи")
            codec_agc_rx_max_gain(:string, "Максимальный уровень усиления принимаемой речи")

            codec_agc_internet_tx_enable(:string, "Включить автоматическую регулировку усиления передаваемой речи во время интернет звонка")
            codec_agc_internet_tx_target_level(:string, "Желаемый уровень передаваемой речи")
            codec_agc_internet_tx_max_gain(:string, "Максимальный уровень усиления передаваемой речи")
            codec_agc_internet_rx_enable(:string, "Включить автоматическую регулировку усиления принимаемой речи")
            codec_agc_internet_rx_target_level(:string, "Желаемый уровень принимаемой речи")
            codec_agc_internet_rx_max_gain(:string, "Максимальный уровень усиления принимаемой речи")
            intercom_id(:string, "intercom_id")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/intercoms/{intercom_id}/settings")
    security [%{Bearer: []}]
    summary("List settings")
    description("List all settings in the database")
    produces("application/json")
    
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.array(:OutputSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end

  def index(conn, params) do
    settings = Intercoms.list_settings(params)
    json(conn, settings)
  end

  swagger_path(:create) do
    post("/api/intercoms/{intercom_id}/settings")
    security [%{Bearer: []}]
    summary("create setting")
    description("create setting in the database")
    produces("application/json")
    
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:setting, :body, Schema.ref(:InputSettings), "The setting details")
    response(201, "OK", Schema.ref(:OutputSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, %{"intercom_id" => intercom_id} = setting_params) do
    intercom = Intercoms.get_intercom(intercom_id)
    with {:ok, %Setting{} = setting} <- Intercoms.create_setting(setting_params),
    {:ok, pid} <- Task.start(fn -> Intercoms.cast_setting_task(intercom.host_name, setting, intercom.serial_key) end) do
      conn
      |> put_status(:created)
      |> json(setting)
    end
  end

  swagger_path(:show) do
    get("/api/intercoms/{intercom_id}/settings/{id}")
    summary("Show setting")
    security [%{Bearer: []}]
    description("Show a setting by ID")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "setting ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    setting = Intercoms.get_setting!(id)
    json(conn, setting)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/intercoms/{intercom_id}/settings/{id}")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    summary("Update setting")
    description("Update attributes of a setting")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "setting ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:setting, :body, %Schema{type: :object}
    |> Schema.property(:setting, Schema.ref(:InputSettings), "The setting details"),
     "The setting details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "setting" => setting_params}) do
    setting = Intercoms.get_setting!(id)
    intercom = Intercoms.get_intercom(setting.intercom_id)
    with {:ok, %Setting{} = setting} <- Intercoms.update_setting(setting, setting_params),
     {:ok, pid} <- Task.start(fn -> Intercoms.cast_setting_task(intercom.host_name, setting, intercom.serial_key) end)do
      json(conn, setting)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/intercoms/{intercom_id}/settings/{id}")
    security [%{Bearer: []}]
    summary("Delete setting")
    description("Delete a setting by ID")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "settings ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    setting = Intercoms.get_setting!(id)

    with {:ok, %Setting{}} <- Intercoms.delete_setting(setting) do
      json(conn, %{})
    end
  end
end
