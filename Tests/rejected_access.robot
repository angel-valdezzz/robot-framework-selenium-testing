*** Settings ***
Documentation    Rechazo de acceso sin depender de usuarios compartidos en el demo.

Resource         ../Config/bootstrap.resource
Resource         ../UseCases/customer_access.resource
Library          DataDriver    file=${CURDIR}/../Data/Test/rejected_access.csv    dialect=excel    encoding=utf-8

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba
Test Template    Rechazar Acceso Del Cliente

Test Tags        e2e    authentication    negative


*** Test Cases ***
Acceso rechazado    username    password    expected_message


*** Keywords ***
Rechazar Acceso Del Cliente
    [Documentation]    Solicita acceso y comprueba el rechazo esperado por cada fila.
    [Arguments]    ${username}    ${password}    ${expected_message}
    When El Cliente Accede A Su Banca En Línea    ${username}    ${password}
    Then El Acceso Del Cliente Es Rechazado    ${expected_message}
