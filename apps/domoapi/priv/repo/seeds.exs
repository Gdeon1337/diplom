# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Domoapi.Repo.insert!(%Domoapi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Domoapi.Repo

alias Domoapi.Users
alias Domoapi.Place
alias Domoapi.Intercoms
alias Domoapi.People
require Logger

company = %Users.Company{}
    |> Users.Company.changeset(%{title: "Test"})
    |> Repo.insert!()

role_admin = %Users.Role{}
    |> Users.Role.changeset(%{title: "admin"})
    |> Repo.insert!()
role_user = %Users.Role{}
    |> Users.Role.changeset(%{title: "user"})
    |> Repo.insert!()

%Users.User{}
    |> Users.User.changeset(%{login: "admin", title: "Admin", raw_password: "admin", role_id: role_admin.id, company_id: company.id})
    |> Repo.insert!()

house = %Place.House{}
    |> Place.House.changeset(%{title: "большой_дом", address: "ул генерала мельникова 1", company_id: company.id})
    |> Repo.insert!()
house_1 = %Place.House{}
    |> Place.House.changeset(%{title: "большой_дом_1", address: "ул генерала мельникова 2", company_id: company.id})
    |> Repo.insert!()
house_2 = %Place.House{}
    |> Place.House.changeset(%{title: "большой_дом_2", address: "ул генерала мельникова 3", company_id: company.id})
    |> Repo.insert!()
house_3 = %Place.House{}
    |> Place.House.changeset(%{title: "большой_дом_3", address: "ул генерала мельникова 4", company_id: company.id})
    |> Repo.insert!()

intercom_1 = %Intercoms.Intercom{}
    |> Intercoms.Intercom.changeset(%{title: "domofon_1", enabled: true, serial_key: "dvsvsdfv23vsd", hardware_version: "v1",software_version: "v2", host_name: "192.158.124.4", company_id: company.id, house_id: house.id})
    |> Repo.insert!()

intercom_2 = %Intercoms.Intercom{}
    |> Intercoms.Intercom.changeset(%{title: "domofon_2", enabled: true, serial_key: "dvsvsdfv43vsd", hardware_version: "v1",software_version: "v2", host_name: "192.158.124.6", company_id: company.id, house_id: house.id})
    |> Repo.insert!()

intercom_3 = %Intercoms.Intercom{}
    |> Intercoms.Intercom.changeset(%{title: "domofon_3", enabled: true, serial_key: "dvsvsdfv54vsd", hardware_version: "v1",software_version: "v2", host_name: "192.158.124.6", company_id: company.id, house_id: house.id})
    |> Repo.insert!()

intercom_4 = %Intercoms.Intercom{}
    |> Intercoms.Intercom.changeset(%{title: "domofon_4", enabled: true, serial_key: "cssvsdfv54vsd", hardware_version: "v1",software_version: "v2", host_name: "192.158.124.6", company_id: company.id, house_id: house.id})
    |> Repo.insert!()

intercom_4 = %Intercoms.Intercom{}
    |> Intercoms.Intercom.changeset(%{title: "domofon_4", enabled: true, serial_key: "cssvsdfv54vsd", hardware_version: "v1",software_version: "v2", host_name: "192.158.124.6", company_id: company.id, house_id: house.id})
    |> Repo.insert!()

apartment_1 = %Place.Apartment{}
    |> Place.Apartment.changeset(%{title: "хз что тут должно быть)", apartment_number: 1, company_id: company.id, house_id: house.id})
    |> Repo.insert!()

apartment_2 = %Place.Apartment{}
    |> Place.Apartment.changeset(%{title: "хз что тут должно быть)", apartment_number: 2, company_id: company.id, house_id: house.id})
    |> Repo.insert!()

apartment_3 = %Place.Apartment{}
    |> Place.Apartment.changeset(%{title: "хз что тут должно быть)", apartment_number: 3, company_id: company.id, house_id: house.id})
    |> Repo.insert!()

apartment_4 = %Place.Apartment{}
    |> Place.Apartment.changeset(%{title: "хз что тут должно быть)", apartment_number: 4, company_id: company.id, house_id: house.id})
    |> Repo.insert!()


people_1 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин", apartment_id: apartment_1.id, company_id: company.id})
    |> Repo.insert!()

people_2 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_1", apartment_id: apartment_1.id, company_id: company.id})
    |> Repo.insert!()

people_3 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_2", apartment_id: apartment_2.id, company_id: company.id})
    |> Repo.insert!()

people_4 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_3", apartment_id: apartment_3.id, company_id: company.id})
    |> Repo.insert!()

people_5 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_4", apartment_id: apartment_3.id, company_id: company.id})
    |> Repo.insert!()

people_6 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_5", apartment_id: apartment_4.id, company_id: company.id})
    |> Repo.insert!()

people_7 = %People.Tenant{}
    |> People.Tenant.changeset(%{title: "Василий Пупкин_6", apartment_id: apartment_4.id, company_id: company.id})
    |> Repo.insert!()

phone_1 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "vnjdsnvjsvsv", tenant_id: people_1.id, company_id: company.id})
    |> Repo.insert!()
phone_2 = %People.Device{}
    |> People.Device.changeset(%{device_type: "vedroid", token: "vnjdsnvjsvsv", tenant_id: people_2.id, company_id: company.id})
    |> Repo.insert!()
phone_3 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "vnvdsjdsnvjsvsv", tenant_id: people_3.id, company_id: company.id})
    |> Repo.insert!()
phone_4 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "vnjds324nvjsvsv", tenant_id: people_4.id, company_id: company.id})
    |> Repo.insert!()
phone_5 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "vnjdsnvj342svsv", tenant_id: people_5.id, company_id: company.id})
    |> Repo.insert!()
phone_6 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "vnjdsnvjsvs53252v", tenant_id: people_6.id, company_id: company.id})
    |> Repo.insert!()
phone_7 = %People.Device{}
    |> People.Device.changeset(%{device_type: "android", token: "v532njdsnvjsvsv", tenant_id: people_7.id, company_id: company.id})
    |> Repo.insert!()

%Place.IntercomsApartments{}
    |> Place.IntercomsApartments.changeset(%{apartment_id: apartment_1.id, intercom_id: intercom_1.id, company_id: company.id})
    |> Repo.insert!()

%Place.IntercomsApartments{}
    |> Place.IntercomsApartments.changeset(%{apartment_id: apartment_2.id, intercom_id: intercom_1.id, company_id: company.id})
    |> Repo.insert!()

%Place.IntercomsApartments{}
    |> Place.IntercomsApartments.changeset(%{apartment_id: apartment_3.id, intercom_id: intercom_1.id, company_id: company.id})
    |> Repo.insert!()

%Place.IntercomsApartments{}
    |> Place.IntercomsApartments.changeset(%{apartment_id: apartment_4.id, intercom_id: intercom_1.id, company_id: company.id})
    |> Repo.insert!()