*** Settings ***
Documentation    Casos de uso de acceso, consulta de cuentas y cierre de sesión.

Variables        ${EXECDIR}/pages/login_page.py
Variables        ${EXECDIR}/pages/accounts_page.py


*** Keywords ***
Iniciar Sesión
    [Documentation]    Autentica al cliente y confirma el acceso a su resumen de cuentas.
    [Arguments]    ${data_table}
    Enviar Credenciales De Acceso    ${data_table}
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.logout}
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.heading}
    Element Text Should Be    ${ACCOUNTS_PAGE.heading}    Accounts Overview

Consultar Cuentas Del Cliente
    [Documentation]    Verifica que el cliente autenticado puede consultar al menos una cuenta.
    [Arguments]    ${data_table}
    Element Should Contain    ${ACCOUNTS_PAGE.welcome}    ${data_table.first_name} ${data_table.last_name}
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.heading}
    Element Text Should Be    ${ACCOUNTS_PAGE.heading}    Accounts Overview
    Wait Until Element Is Visible    ${ACCOUNTS_PAGE.first_account}

Cerrar Sesión
    [Documentation]    Finaliza el acceso y confirma que se solicita iniciar sesión.
    Click Element    ${ACCOUNTS_PAGE.logout}
    Wait Until Element Is Visible    ${LOGIN_PAGE.submit}
    Page Should Not Contain Element    ${ACCOUNTS_PAGE.logout}

Validar Rechazo De Acceso
    [Documentation]    Solicita acceso y comprueba el rechazo esperado y la ausencia de sesión.
    [Arguments]    ${data_table}
    Enviar Credenciales De Acceso    ${data_table}
    Wait Until Element Is Visible    ${LOGIN_PAGE.error}
    Element Text Should Be    ${LOGIN_PAGE.error}    ${data_table.expected_message}
    Page Should Not Contain Element    ${ACCOUNTS_PAGE.logout}

Enviar Credenciales De Acceso
    [Documentation]    Completa y envía el formulario de autenticación.
    [Tags]    robot:private
    [Arguments]    ${credentials}
    Wait Until Element Is Visible    ${LOGIN_PAGE.username}
    Input Text    ${LOGIN_PAGE.username}    ${credentials.username}
    Input Password    ${LOGIN_PAGE.password}    ${credentials.password}
    Click Element    ${LOGIN_PAGE.submit}
