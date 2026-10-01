*** Settings ***
Documentation    Caso de uso de registro de un cliente en banca en línea.

Variables        ${EXECDIR}/pages/registration_page.py
Variables        ${EXECDIR}/pages/accounts_page.py


*** Keywords ***
Registrar Cliente
    [Documentation]    Completa el alta y confirma que el cliente quedó registrado con acceso habilitado.
    [Arguments]    ${data_table}
    Click Element    ${REGISTRATION_PAGE.open_registration}
    Wait Until Element Is Visible    ${REGISTRATION_PAGE.first_name}
    Completar Información Personal    ${data_table}
    Definir Credenciales Del Cliente    ${data_table}
    Click Element    ${REGISTRATION_PAGE.submit}
    Confirmar Registro Del Cliente    ${data_table}

Completar Información Personal
    [Documentation]    Completa los datos personales y de contacto del formulario.
    [Tags]    robot:private
    [Arguments]    ${data_table}
    Input Text    ${REGISTRATION_PAGE.first_name}    ${data_table.first_name}
    Input Text    ${REGISTRATION_PAGE.last_name}    ${data_table.last_name}
    Input Text    ${REGISTRATION_PAGE.street}    ${data_table.street}
    Input Text    ${REGISTRATION_PAGE.city}    ${data_table.city}
    Input Text    ${REGISTRATION_PAGE.state}    ${data_table.state}
    Input Text    ${REGISTRATION_PAGE.zip_code}    ${data_table.zip_code}
    Input Text    ${REGISTRATION_PAGE.phone}    ${data_table.phone}
    Input Text    ${REGISTRATION_PAGE.ssn}    ${data_table.ssn}

Definir Credenciales Del Cliente
    [Documentation]    Define el usuario, la contraseña y su confirmación.
    [Tags]    robot:private
    [Arguments]    ${data_table}
    Input Text    ${REGISTRATION_PAGE.username}    ${data_table.username}
    Input Password    ${REGISTRATION_PAGE.password}    ${data_table.password}
    Input Password    ${REGISTRATION_PAGE.confirm_password}    ${data_table.password}

Confirmar Registro Del Cliente
    [Documentation]    Confirma el usuario registrado y la habilitación de su sesión.
    [Tags]    robot:private
    [Arguments]    ${data_table}
    Wait Until Element Is Visible    ${REGISTRATION_PAGE.confirmation}
    Element Text Should Be    ${REGISTRATION_PAGE.confirmation}    Welcome ${data_table.username}
    Element Should Contain    ${REGISTRATION_PAGE.message}    Your account was created successfully.
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.logout}
