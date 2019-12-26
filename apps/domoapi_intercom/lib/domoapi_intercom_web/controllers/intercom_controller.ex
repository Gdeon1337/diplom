defmodule DomoapiIntercomWeb.IntercomController do
  use DomoapiIntercomWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Intercoms
  alias Domoapi.Place
  alias Domoapi.People
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Place.IntercomsApartments
  require Logger
  action_fallback DomoapiIntercomWeb.FallbackController

  def swagger_definitions do
    %{
      OutputApartments:
        swagger_schema do
          title("output aprtment")
          properties do
            id(:string, "Apartment ID")
            apartment_number(:integer, "Numbert apartment")
            house_id(:string, "House ID")
        end
      end,
      OutputKeys:
        swagger_schema do
          title("output keys")
          properties do
            key(:string, "key data")
            type(:string, "type key")
        end
      end,
      OutputSettings:
        swagger_schema do
          title("output settings")
          properties do
            max_ring_duration_ms(:string, "max_ring_duration_ms")
            max_call_duration_ms(:string, "max_call_duration_ms")
            door_open_time_ms(:string, "door_open_time_ms")
            first_room_number(:string, "first_room_number")
            max_threshold(:string, "Нижний порог сигнала линии")
            mix_threshold(:string, "Верхний порог сигнала линии")

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
        end
      end,
      OutputApartmentSettings:
          swagger_schema do
            title("output apartment_settings")
            properties do
              clean(:string, "Включение стандартных настроек")
              enabled(:string, "Включение обслуживания данной квартиры")
              min_threshold(:string, "Нижний порог сигнала линии")
              max_threshold(:string, "Верхний порог сигнала линии")

              codec_rx_vol(:string, "Громкость приема речи")
              codec_tx_vol(:string, "Громкость передачи речи")

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
          end
      end,
      OutputTenants:
        swagger_schema do
          title("output tenant")
          properties do
            id(:string, "Tenant ID")
            title(:string, "Name Tenant")
            phone_number(:string, "Number of phone")
            apartment_id(:string, "Apartment ID")
        end
      end,
      OutputPhotos:
        swagger_schema do
          title("output photo")
          properties do
            id(:string, "Intercopms ID")
            title(:string, "Photo data")
            photo_base64(:string, "data Photo base64")
            tenant_id(:string, "Tenant ID")
        end
      end
  }
  end

  swagger_path(:index_apartments) do
    get("/intercoms/apartments")
    security [%{Bearer: []}]
    summary("List apartments")
    description("List all apartments in the database")
    produces("application/json")
    response(200, "OK", Schema.array(:OutputApartments))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_apartments(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    apartments = Place.list_apartments(params)
    json(conn, apartments)
  end

  swagger_path(:index_keys) do
    get("/intercoms/keys")
    security [%{Bearer: []}]
    summary("List keys")
    description("List all keys in the database")
    produces("application/json")
    response(200, "OK", Schema.array(:OutputKeys))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_keys(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    keys = Intercoms.list_keys(params)
    json(conn, keys)
  end
  
  swagger_path(:index_global_settings) do
    get("/intercoms/global_settings")
    security [%{Bearer: []}]
    summary("List global_settings")
    description("List all global_settings in the database")
    produces("application/json")
    response(200, "OK", Schema.array(:OutputSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_global_settings(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    settings = Intercoms.list_settings(params)
    json(conn, settings)
  end

  swagger_path(:index_room_settings) do
    get("/intercoms/room_settings")
    security [%{Bearer: []}]
    summary("List room_settings")
    description("List all room_settings in the database")
    produces("application/json")
    parameter(:apartment_number, :query, :integer, "apartment_number", required: true, example: "1")
    response(200, "OK", Schema.array(:OutputApartmentSettings))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_room_settings(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    settings = Place.list_apartment_settings(params)
    json(conn, settings)
  end

  swagger_path(:index_tenants) do
    get("/intercoms/tenants")
    security [%{Bearer: []}]
    summary("List tenants")
    description("List all tenants in the database")
    produces("application/json")
    response(200, "OK", Schema.array(:OutputTenants))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_tenants(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    settings = People.list_tenants(params)
    json(conn, settings)
  end

  swagger_path(:index_tenant_photo) do
    get("/intercoms/photos")
    security [%{Bearer: []}]
    summary("List tenants")
    description("List all photos in the database")
    produces("application/json")
    parameter(:apartment_number, :query, :integer, "apartment_number", required: true, example: "1")
    response(200, "OK", Schema.array(:OutputPhotos))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index_tenant_photo(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    params = Map.put(params, "intercom_serial_key", intercom_serial_key)
    photos = People.list_photos(params)
    json(conn, photos)
  end

  swagger_path(:update_host) do
    security [%{Bearer: []}]
    put("/intercoms/update_host")
    summary("Update intercom host")
    description("Update host of a intercoms")
    consumes("application/json")
    produces("application/json")
    parameter(:host_name, :body, :string, "The Intercoms details")
    response(200, "Updated Successfully", %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update_host(conn, params) do
    intercom_serial_key = conn.assigns[:intercom_serial_key]
    intercom = Intercoms.check_intercom(intercom_serial_key)
    with {:ok, %Domoapi.Intercoms.Intercom{} = intercom} <- Intercoms.update_intercom(intercom, params) do
      Intercoms.update_all_cameras(intercom)
      json(conn, %{})
    end
  end

end
