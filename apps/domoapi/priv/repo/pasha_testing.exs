
alias Domoapi.Users
alias Domoapi.Place
alias Domoapi.Place.{
    Apartment,
    IntercomsApartments
}
alias Domoapi.Intercoms.Intercom
alias Domoapi.People.{
    Tenant,
    Device
}
alias Domoapi.People
alias Domoapi.Repo
require Logger

intercom = %Intercom{
    title: "Паша интерком",
    enabled: true,
    serial_key: "02c00081fd97650e",
    hardware_version: "bad hardware",
    software_version: "bad software",
    host_name: "http://192.168.1.72:17002",
    deleted: false
} |> Repo.insert!()

apartment = %Apartment{
    deleted: false,
    apartment_number: 121
} |> Repo.insert!()

intercoms_apartments = %IntercomsApartments{
    apartment_id: apartment.id,
    intercom_id: intercom.id
} |> Repo.insert!()

tenant = %Tenant{
    title: "хата",
    deleted: false,
    apartment_id: apartment.id
} |> Repo.insert!()

device = %Device{
    device_type: "android",
    deleted: false,
    token: "drv5vbAPBDk:APA91bESsW5QF6icxgcfHCWTGlZkG69bicqNAZ8F33UMkrOQtC3UVl4hu7r8CyGrieIST0H7Giek7G5cslVwPp7DUx98CV2JwxFOWF4vIpzDTcOWskxquSMJgVDEgy3DioQY3namZ71j",
    tenant_id: tenant.id
} |> Repo.insert!()

device = %Device{
    device_type: "android",
    deleted: false,
    token: "eVEb8c2mgBM:APA91bFaFwaZveuc8UKU3yXacAAWmGGBYBCCEq-qOe_6iYsTYFwdbjFjtSSGmUtRmlY2Hin6INkGb7k2Lroc4MaXXi-qEsEFwxORMpho2JpBUasnqqbh4Q7iycSeSqvkHfABF2LLbUaf",
    tenant_id: tenant.id
} |> Repo.insert!()