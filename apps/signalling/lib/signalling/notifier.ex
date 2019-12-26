defmodule Signalling.Notifier do
    require Logger
    alias Pigeon.APNS
    alias Pigeon.FCM
    alias Pigeon.APNS.Notification, as: IOSNotification
    alias Pigeon.FCM.Notification, as: AndroidNotification
    alias Domoapi.People.{
        Tenant,
        Device
    }

    def notify_tenants_about_call(params, tenants) do
        Logger.info("Notifying... ##{inspect(tenants)}")
        tenants
        |> Task.async_stream(&(notify_tenant_about_call(&1, params)), max_concurrency: 100)
        |> Stream.run()
    end

    defp notify_tenant_about_call(%Tenant{devices: devices}, params) do
        devices
        |> Task.async_stream(&(notify_device_about_call(&1, params)), max_concurrency: 100)
        |> Stream.run()
    end

    def notify_tenant_about_break_call(tenants) do
        tenants
        |> Enum.map(&break_call/1)
    end

    def break_call(%Tenant{devices: devices}) do
        devices
        |> Task.async_stream(&(notify_device_about_break_call(&1)), max_concurrency: 100)
        |> Stream.run()
    end

    def sdp_call(%Tenant{devices: devices}, params) do
         devices
        |> Task.async_stream(&(notify_tenant_about_sdp_call(&1, params)), max_concurrency: 100)
        |> Stream.run()
    end

    defp notify_tenant_about_sdp_call(devices, params) do
        Task.start(fn -> notify_device_sdp_call(devices, params) end)
    end

    defp notify_device_sdp_call(%Device{device_type: "Android", token: device_token}, params) do
        Logger.info("Sending call notification to ##{device_token}")
        payload = call_sdp_payload(params)
        notification = AndroidNotification.new(device_token)
            |> AndroidNotification.put_notification(%{"body" => ""})
            |> AndroidNotification.put_data(payload)
        case FCM.push(notification) do
            %AndroidNotification{status: succes} -> Logger.info("Notification to: #{device_token} was succesfully deliever, payload: #{inspect(payload)}")
            error -> Logger.error("Error during notification delivery - device_token:#{device_token}, error:#{inspect(error)}")
        end
    end



    defp notify_tenant_about_break_call(%Tenant{devices: devices}, params) do
        Task.start(fn -> notify_device_about_break_call(devices) end)
    end

    defp notify_device_about_call(%Device{device_type: "Android", token: device_token}, params) do
        Logger.info("Sending call notification to ##{device_token}")
        payload = call_payload(params)
        notification = AndroidNotification.new(device_token)
            |> AndroidNotification.put_notification(%{"body" => "На ваш домофон поступил звонок"})
            |> AndroidNotification.put_data(payload)
        case FCM.push(notification) do
            %AndroidNotification{status: succes} -> Logger.info("Notification to: #{device_token} was succesfully deliever, payload: #{inspect(payload)}")
            error -> Logger.error("Error during notification delivery - device_token:#{device_token}, error:#{inspect(error)}")
        end
    end

    def notify_device_about_break_call(%Device{device_type: "Android", token: device_token}) do
        Logger.info("Sending call notification to ##{device_token}")
        notification = AndroidNotification.new(device_token)
          |> AndroidNotification.put_notification(%{"body" => "Домофон сбросили"})
        case FCM.push(notification) do
            %AndroidNotification{status: succes} -> Logger.info("Notification to: #{device_token} was succesfully deliever")
            error -> Logger.error("Error during notification delivery - device_token:#{device_token}, error:#{inspect(error)}")
        end
    end

    defp notify_device_about_call(%Device{device_type: "iphone", token: device_token}, params) do
        payload = call_payload(params)
        notification = IOSNotification.new(payload, device_token)
        case APNS.push(notification) do
            %IOSNotification{response: succes} -> Logger.info("Notification to: #{device_token} was succesfully deliever, payload: #{inspect(payload)}")
            error -> Logger.error("Error during notification delivery - device_token:#{device_token}, error:#{inspect(error)}")
        end
    end

    defp call_sdp_payload({candidate}), do: %{
        "candidate" => candidate
    }

    defp call_payload({session_id, audio_port, apartment_id, sdp, candidate}), do: %{
        "apartment_id" => apartment_id,
        "session_id" => session_id,
        "audio_port" => audio_port,
        "sdp" => sdp,
        "candidate" => candidate,
        "notification_type" => "call",
                "actions" => [
            %{
              "title" => "Ответить",
              "callback" => "respondCallback",
              "foreground" => true
            },
            %{
              "title" => "Отклонить",
              "callback" => "declineCallback",
              "foreground" => false
            }
        ]

    }

    def test() do
        Pigeon.FCM.Notification.new("eVEb8c2mgBM:APA91bFaFwaZveuc8UKU3yXacAAWmGGBYBCCEq-qOe_6iYsTYFwdbjFjtSSGmUtRmlY2Hin6INkGb7k2Lroc4MaXXi-qEsEFwxORMpho2JpBUasnqqbh4Q7iycSeSqvkHfABF2LLbUaf")
        |> Pigeon.FCM.Notification.put_notification(%{"body" => "Открой дверь"})
        |> Pigeon.FCM.Notification.put_data(call_payload({"my cool session", 8010, 128}))
        |> Pigeon.FCM.push()
    end
end
