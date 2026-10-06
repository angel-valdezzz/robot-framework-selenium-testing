*** Settings ***
Documentation    Recorridos bancarios completos con datos sintéticos independientes.

Resource         ${EXECDIR}/config/evidence.resource
Resource         ${EXECDIR}/config/browser.resource
Resource         ${EXECDIR}/config/test_data.resource
Resource         ${EXECDIR}/use_cases/customer_banking.resource

Test Setup       Abrir Navegador De Prueba
Test Teardown    Cerrar Navegador De Prueba

Test Tags        e2e    banking


*** Test Cases ***
Cliente Se Registra Y Finaliza Su Sesión
    [Documentation]    Confirma el alta y cierre sin depender del resumen de cuentas.
    ${customer}=    Cargar Datos Del Cliente    0
    Registrar Cliente Con Evidencia    ${customer}
    Cerrar Sesión
    Documentar Sesión Finalizada

Cliente Abre Una Cuenta De Ahorro Y Consulta Su Saldo
    [Documentation]    Registro, acceso, apertura, consulta y cierre en la misma sesión.
    Preparar Cliente Bancario
    ${source}    ${target}=    Abrir Cuenta De Ahorro
    Should Not Be Empty    ${source}
    ${balance}=    Consultar Saldo De Cuenta    ${target}
    Should Be True    $balance >= 0
    Documentar Resultado Bancario    ${BANKING_PAGE.account_id}    Cuenta de ahorro consultada    3
    Cerrar Sesión

Cliente Transfiere Y Comprueba Saldos Y Movimientos
    [Documentation]    Verifica que el débito y crédito reflejan exactamente el importe enviado.
    Preparar Cliente Bancario
    Transferir Y Comprobar Saldos Y Movimientos
    Cerrar Sesión


*** Keywords ***
Preparar Cliente Bancario
    [Documentation]    Crea credenciales únicas y comprueba el acceso al resumen.
    ${customer}=    Cargar Datos Del Cliente    0
    Registrar Cliente Con Evidencia    ${customer}
    Cerrar Sesión
    Iniciar Sesión    ${customer}
