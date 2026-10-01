*** Settings ***
Documentation    Cada fila prepara un cliente y compone sus casos de uso completos.

Resource         ${EXECDIR}/config/browser.resource
Resource         ${EXECDIR}/config/test_data.resource
Resource         ${EXECDIR}/use_cases/customer_registration.resource
Resource         ${EXECDIR}/use_cases/customer_access.resource
Library          DataDriver    file=${EXECDIR}/data/test/customer_journey.csv    dialect=excel    encoding=utf-8

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba
Test Template    Registrar Cliente Y Consultar Sus Cuentas

Test Tags        e2e    customer    smoke


*** Test Cases ***
Cliente ${customer_id} puede registrarse y consultar sus cuentas    customer_id


*** Keywords ***
Registrar Cliente Y Consultar Sus Cuentas
    [Documentation]    Prepara la fila de datos y ejecuta registro, acceso, consulta y cierre.
    [Arguments]    ${customer_id}
    ${customer}=    Cargar Datos Del Cliente    ${customer_id}
    Registrar Cliente    ${customer}
    Cerrar Sesión
    Iniciar Sesión    ${customer}
    Consultar Cuentas Del Cliente    ${customer}
    Cerrar Sesión
