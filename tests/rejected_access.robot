*** Settings ***
Documentation    Cada fila identifica un caso de rechazo con sus datos separados del escenario.

Resource         ${EXECDIR}/config/browser.resource
Resource         ${EXECDIR}/config/test_data.resource
Resource         ${EXECDIR}/use_cases/customer_access.resource
Library          DataDriver    file=${EXECDIR}/data/test/rejected_access.csv    dialect=excel    encoding=utf-8

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba
Test Template    Rechazar Acceso Del Cliente

Test Tags        e2e    authentication    negative


*** Test Cases ***
Acceso rechazado    row_index


*** Keywords ***
Rechazar Acceso Del Cliente
    [Documentation]    Carga la fila de acceso y ejecuta el caso de uso de rechazo.
    [Arguments]    ${row_index}
    ${access}=    Cargar Datos De Acceso    ${row_index}
    Validar Rechazo De Acceso    ${access}
