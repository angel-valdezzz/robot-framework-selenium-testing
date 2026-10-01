*** Settings ***
Documentation    Cada fila crea su propio cliente y prueba registro, acceso y cierre.

Resource         ../Config/bootstrap.resource
Resource         ../UseCases/customer_registration.resource
Resource         ../UseCases/customer_access.resource
Library          DataDriver    file=${CURDIR}/../Data/Test/customer_journey.csv    dialect=excel    encoding=utf-8

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba
Test Template    Registrar Cliente Y Consultar Sus Cuentas

Test Tags        e2e    customer    smoke


*** Test Cases ***
Cliente ${customer_id} puede registrarse y consultar sus cuentas    customer_id


*** Keywords ***
Registrar Cliente Y Consultar Sus Cuentas
    [Documentation]    Compone los datos y expresa el escenario con intención de negocio.
    [Arguments]    ${customer_id}
    ${customer}=    Preparar Cliente De Prueba    ${customer_id}
    When El Cliente Solicita Su Alta En Banca En Línea    ${customer}
    Then El Cliente Queda Registrado En Banca En Línea    ${customer}
    When El Cliente Cierra Su Sesión
    And El Cliente Accede A Su Banca En Línea    ${customer.username}    ${customer.password}
    Then El Cliente Puede Consultar Sus Cuentas
    When El Cliente Cierra Su Sesión
