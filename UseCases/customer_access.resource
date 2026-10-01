*** Settings ***
Documentation    Acceso del cliente, cierre de sesión y rechazo de credenciales.

Variables        ../Pages/login_page.py
Variables        ../Pages/accounts_page.py


*** Keywords ***
El Cliente Accede A Su Banca En Línea
    [Documentation]    Solicita el acceso usando las credenciales indicadas.
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${login_page.username}
    Input Text    ${login_page.username}    ${username}
    Input Password    ${login_page.password}    ${password}
    Click Element    ${login_page.submit}

El Cliente Puede Consultar Sus Cuentas
    [Documentation]    Verifica el resumen y al menos una cuenta disponible.
    Wait Until Element Is Visible    ${accounts_page.heading}
    Element Text Should Be    ${accounts_page.heading}    Accounts Overview
    Wait Until Element Is Visible    ${accounts_page.first_account}

El Cliente Cierra Su Sesión
    [Documentation]    Finaliza el acceso y verifica que se solicita iniciar sesión.
    Click Element    ${accounts_page.logout}
    Wait Until Element Is Visible    ${login_page.submit}

El Acceso Del Cliente Es Rechazado
    [Documentation]    Valida el mensaje de rechazo y la ausencia de sesión.
    [Arguments]    ${expected_message}
    Wait Until Element Is Visible    ${login_page.error}
    Element Text Should Be    ${login_page.error}    ${expected_message}
    Page Should Not Contain Element    ${accounts_page.logout}
