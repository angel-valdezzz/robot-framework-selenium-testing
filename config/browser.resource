*** Settings ***
Documentation    Infraestructura del navegador compuesta por las suites.

Variables        ${EXECDIR}/config/settings.py
Library          SeleniumLibrary    timeout=${TIMEOUT}    run_on_failure=Capture Page Screenshot


*** Keywords ***
Abrir Navegador De Prueba
    [Documentation]    Crea una sesión aislada para cada caso de prueba.
    Open Browser    ${BASE_URL}    ${BROWSER}    options=${BROWSER_OPTIONS}
    Set Window Size    1440    1000
    Set Selenium Speed    ${SELENIUM_SPEED}

Cerrar Navegador De Prueba
    [Documentation]    Cierra las sesiones aun cuando el escenario falla.
    Close All Browsers
