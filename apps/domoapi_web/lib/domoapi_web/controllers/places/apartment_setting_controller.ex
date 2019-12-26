defmodule DomoapiWeb.ApartmentSettingContoller do
    use DomoapiWeb, :controller
    use PhoenixSwagger
    alias Domoapi.Place
    alias Domoapi.Place.ApartmentSetting

    plug DomoapiWeb.Plugs.CustomAuthorization
    action_fallback DomoapiWeb.FallbackController

    def swagger_definitions do
    %{
        OutputApartmentSettings:
          swagger_schema do
            title("output apartment_settings")
            properties do
              id(:string, "Setting ID")
              clean(:string, "Включение стандартных настроек")
              enabled(:string, "Включение обслуживания данной квартиры")
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
              apartment_id(:string, "apartment_id")
          end
        end,
        InputApartmentSettings:
          swagger_schema do
            title("input apartment_settings")
            properties do
              clean(:string, "Включение стандартных настроек")
              enabled(:string, "Включение обслуживания данной квартиры")
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
              apartment_id(:string, "apartment_id")
          end
        end
      }
    end
  
    swagger_path(:index) do
      get("/api/apartments/{apartment_id}/apartment_settings")
      security [%{Bearer: []}]
      summary("List apartment_settings")
      description("List all apartment_settings in the database")
      produces("application/json")
      
      parameter(:apartment_id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      response(200, "OK", Schema.array(:OutputApartmentSettings))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
      response(415, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
  
    def index(conn, params) do
      apartment_settings = Place.list_apartment_settings(params)
      json(conn, apartment_settings)
    end
  
    swagger_path(:create) do
      post("/api/apartments/{apartment_id}/apartment_settings")
      security [%{Bearer: []}]
      summary("create apartment_setting")
      description("create apartment_setting in the database")
      produces("application/json")
      
      parameter(:apartment_id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      parameter(:apartment_setting, :body, Schema.ref(:InputApartmentSettings), "The apartment_setting details")
      response(201, "OK", Schema.ref(:OutputApartmentSettings))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
      response(422, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def create(conn, apartment_setting_params) do
      with {:ok, %ApartmentSetting{} = apartment_setting} <- Place.create_apartment_setting(apartment_setting_params) do
        conn
        |> put_status(:created)
        |> json(apartment_setting)
      end
    end
  
    swagger_path(:show) do
      get("/api/apartments/{apartment_id}/apartment_settings/{id}")
      summary("Show apartment_setting")
      security [%{Bearer: []}]
      description("Show a apartment_setting by ID")
      produces("application/json")
      parameter(:apartment_id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      parameter(:id, :path, :string, "apartment_setting ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      response(200, "OK", Schema.ref(:OutputApartmentSettings))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def show(conn, %{"id" => id}) do
      apartment_setting = Place.get_apartment_setting!(id)
      json(conn, apartment_setting)
    end
  
    swagger_path(:update) do
      security [%{Bearer: []}]
      put("/api/apartments/{apartment_id}/apartment_settings/{id}")
      parameter(:apartment_id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      summary("Update apartment_setting")
      description("Update attributes of a apartment_setting")
      consumes("application/json")
      produces("application/json")
      parameters do
        id(:path, :string, "apartment_setting ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      end
      parameter(:apartment_setting, :body, %Schema{type: :object}
      |> Schema.property(:apartment_setting, Schema.ref(:InputApartmentSettings), "The apartment_setting details"),
        "The apartment_setting details", required: true)
      response(200, "Updated Successfully", Schema.ref(:OutputApartmentSettings))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
      response(422, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def update(conn, %{"id" => id, "apartment_setting" => setting_params}) do
      apartment_setting = Place.get_apartment_setting!(id)
  
      with {:ok, %ApartmentSetting{} = apartment_setting} <- Place.update_apartment_setting(apartment_setting, setting_params) do
        json(conn, apartment_setting)
      end
    end
  
    swagger_path(:delete) do
      PhoenixSwagger.Path.delete("/api/apartments/{apartment_id}/apartment_settings/{id}")
      security [%{Bearer: []}]
      summary("Delete apartment_setting")
      description("Delete a apartment_setting by ID")
      parameter(:apartment_id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      parameter(:id, :path, :string, "apartment_settings ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      response(200, %{})
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def delete(conn, %{"id" => id}) do
      apartment_setting = Place.get_apartment_setting!(id)
  
      with {:ok, %ApartmentSetting{}} <- Place.delete_apartment_setting(apartment_setting) do
        json(conn, %{})
      end
    end
  end
  