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
    Documentar Sesión Finalizada

Documentar Sesión Finalizada
    [Documentation]    Anota y captura el cierre de sesión; retira las marcas al terminar.
    Highlight Element    ${LOGIN_PAGE.submit}    color=coral    style=dashed    group=session
    Add Label    ${LOGIN_PAGE.submit}    text=Sesión cerrada    position=right    group=session
    TRY
        Capture Page Evidence    Sesión finalizada    status=PASS
    FINALLY
        Clear Annotations    group=session
    END

Registrar Cliente Con Evidencia
    [Documentation]    Ejecuta el caso de uso completo y registra la confirmación del alta.
    [Arguments]    ${data_table}
    ${milestone}=    Create Milestone    Cliente registrado
    Registrar Cliente    ${data_table}
    Highlight Element
    ...    ${REGISTRATION_PAGE.confirmation}
    ...    color=coral
    ...    background=rgba(240,100,69,0.12)
    ...    group=registration
    Add Dot    ${REGISTRATION_PAGE.confirmation}    text=1    position=right    group=registration
    Add Label    ${REGISTRATION_PAGE.confirmation}    text=Alta confirmada    position=top    group=registration
    Add Note    ${ACCOUNTS_PAGE.logout}    text=El cliente ya tiene acceso    position=left    group=registration
    TRY
        Capture Page Evidence    Alta confirmada    milestone_id=${milestone}    status=PASS
    FINALLY
        Clear Annotations    group=registration
    END

Consultar Cuentas Con Evidencia
    [Documentation]    Verifica las cuentas y documenta el resultado en el hito solicitado.
    [Arguments]    ${data_table}    ${milestone}
    Consultar Cuentas Del Cliente    ${data_table}
    Highlight Element    ${ACCOUNTS_PAGE.heading}    color=coral    group=accounts
    Highlight Element    ${ACCOUNTS_PAGE.first_account}    color=coral    group=accounts
    Add Dot    ${ACCOUNTS_PAGE.first_account}    text=2    position=right    group=accounts
    Add Note    ${ACCOUNTS_PAGE.heading}    text=Cuenta disponible para el cliente    position=right    group=accounts
    TRY
        Capture Element Evidence
        ...    ${ACCOUNTS_PAGE.heading}
        ...    Resumen de cuentas
        ...    milestone_id=${milestone}
        ...    status=PASS
        Capture Page Evidence    Cuentas disponibles    milestone_id=${milestone}    status=PASS
    FINALLY
        Clear Annotations    group=accounts
    END
