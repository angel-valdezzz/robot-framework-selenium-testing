*** Settings ***
Documentation    Cada fila prepara un cliente y compone sus casos de uso completos.

Resource         ${EXECDIR}/config/browser.resource
Resource         ${EXECDIR}/config/evidence.resource
Resource         ${EXECDIR}/config/test_data.resource
Resource         ${EXECDIR}/use_cases/customer_registration.resource
Resource         ${EXECDIR}/use_cases/customer_access.resource
Library          DataDriver    file=${EXECDIR}/data/test/customer_journey.csv    dialect=excel    encoding=utf-8

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba
Test Template    Registrar Cliente Y Consultar Sus Cuentas

Test Tags        e2e    customer    smoke


*** Test Cases ***
Cliente ${row_index} puede registrarse y consultar sus cuentas    row_index


*** Keywords ***
Registrar Cliente Y Consultar Sus Cuentas
    [Documentation]    Prepara la fila de datos y ejecuta registro, acceso, consulta y cierre.
    [Arguments]    ${row_index}
    ${data_table}=    Cargar Datos Del Cliente    ${row_index}
    Set Report Metadata    Aplicación=ParaBank    Ambiente=Demo público    Fila=${row_index}
    Registrar Cliente Con Evidencia    ${data_table}
    Cerrar Sesión
    ${access}=    Create Milestone    Acceso y consulta de cuentas
    Iniciar Sesión    ${data_table}
    Consultar Cuentas Con Evidencia    ${data_table}    ${access}
    Cerrar Sesión
    Capture Page Evidence    Sesión finalizada    status=PASS

Registrar Cliente Con Evidencia
    [Documentation]    Ejecuta el caso de uso completo y registra la confirmación del alta.
    [Arguments]    ${data_table}
    ${milestone}=    Create Milestone    Cliente registrado
    Registrar Cliente    ${data_table}
    Capture Page Evidence    Alta confirmada    milestone_id=${milestone}    status=PASS

Consultar Cuentas Con Evidencia
    [Documentation]    Verifica las cuentas y documenta el resultado en el hito solicitado.
    [Arguments]    ${data_table}    ${milestone}
    Consultar Cuentas Del Cliente    ${data_table}
    Capture Element Evidence
    ...    ${ACCOUNTS_PAGE.heading}
    ...    Resumen de cuentas
    ...    milestone_id=${milestone}
    ...    status=PASS
    Capture Page Evidence    Cuentas disponibles    milestone_id=${milestone}    status=PASS
