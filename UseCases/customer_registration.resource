*** Settings ***
Documentation    Flujo de alta de un cliente con acceso a banca en línea.

Variables        ../Pages/registration_page.py
Variables        ../Pages/accounts_page.py


*** Keywords ***
El Cliente Solicita Su Alta En Banca En Línea
    [Documentation]    Completa y envía el registro con los datos del cliente.
    [Arguments]    ${customer}
    Click Element    ${registration_page.open_registration}
    Wait Until Element Is Visible    ${registration_page.first_name}
    Registrar Información Personal Del Cliente    ${customer}
    Definir Credenciales De Banca En Línea    ${customer}
    Click Element    ${registration_page.submit}

Registrar Información Personal Del Cliente
    [Documentation]    Completa los datos personales y de contacto del alta.
    [Arguments]    ${customer}
    Input Text    ${registration_page.first_name}    ${customer.first_name}
    Input Text    ${registration_page.last_name}    ${customer.last_name}
    Input Text    ${registration_page.street}    ${customer.street}
    Input Text    ${registration_page.city}    ${customer.city}
    Input Text    ${registration_page.state}    ${customer.state}
    Input Text    ${registration_page.zip_code}    ${customer.zip_code}
    Input Text    ${registration_page.phone}    ${customer.phone}
    Input Text    ${registration_page.ssn}    ${customer.ssn}

Definir Credenciales De Banca En Línea
    [Documentation]    Define el usuario, la contraseña y su confirmación.
    [Arguments]    ${customer}
    Input Text    ${registration_page.username}    ${customer.username}
    Input Password    ${registration_page.password}    ${customer.password}
    Input Password    ${registration_page.confirm_password}    ${customer.password}

El Cliente Queda Registrado En Banca En Línea
    [Documentation]    Confirma el nombre de usuario y la habilitación del acceso.
    [Arguments]    ${customer}
    Wait Until Element Is Visible    ${registration_page.confirmation}
    Element Text Should Be    ${registration_page.confirmation}    Welcome ${customer.username}
    Element Should Contain    ${registration_page.message}    Your account was created successfully.
    Wait Until Element Is Visible    ${accounts_page.logout}
