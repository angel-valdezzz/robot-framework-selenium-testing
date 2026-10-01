*** Settings ***
Documentation    Caso de uso de registro de un cliente en banca en línea.

Variables        ${EXECDIR}/pages/registration_page.py
Variables        ${EXECDIR}/pages/accounts_page.py


*** Keywords ***
Registrar Cliente
    [Documentation]    Completa el alta y confirma que el cliente quedó registrado con acceso habilitado.
    [Arguments]    ${customer}
    Click Element    ${REGISTRATION_PAGE.open_registration}
    Wait Until Element Is Visible    ${REGISTRATION_PAGE.first_name}
    Completar Información Personal    ${customer}
    Definir Credenciales Del Cliente    ${customer}
    Click Element    ${REGISTRATION_PAGE.submit}
    Confirmar Registro Del Cliente    ${customer}

Completar Información Personal
    [Documentation]    Completa los datos personales y de contacto del formulario.
    [Tags]    robot:private
    [Arguments]    ${customer}
    Input Text    ${REGISTRATION_PAGE.first_name}    ${customer.first_name}
    Input Text    ${REGISTRATION_PAGE.last_name}    ${customer.last_name}
    Input Text    ${REGISTRATION_PAGE.street}    ${customer.street}
    Input Text    ${REGISTRATION_PAGE.city}    ${customer.city}
    Input Text    ${REGISTRATION_PAGE.state}    ${customer.state}
    Input Text    ${REGISTRATION_PAGE.zip_code}    ${customer.zip_code}
    Input Text    ${REGISTRATION_PAGE.phone}    ${customer.phone}
    Input Text    ${REGISTRATION_PAGE.ssn}    ${customer.ssn}

Definir Credenciales Del Cliente
    [Documentation]    Define el usuario, la contraseña y su confirmación.
    [Tags]    robot:private
    [Arguments]    ${customer}
    Input Text    ${REGISTRATION_PAGE.username}    ${customer.username}
    Input Password    ${REGISTRATION_PAGE.password}    ${customer.password}
    Input Password    ${REGISTRATION_PAGE.confirm_password}    ${customer.password}

Confirmar Registro Del Cliente
    [Documentation]    Confirma el usuario registrado y la habilitación de su sesión.
    [Tags]    robot:private
    [Arguments]    ${customer}
    Wait Until Element Is Visible    ${REGISTRATION_PAGE.confirmation}
    Element Text Should Be    ${REGISTRATION_PAGE.confirmation}    Welcome ${customer.username}
    Element Should Contain    ${REGISTRATION_PAGE.message}    Your account was created successfully.
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.logout}
