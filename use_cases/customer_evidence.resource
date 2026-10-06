*** Settings ***
Documentation    Evidencias y anotaciones reutilizables de los recorridos de clientes.

Resource         ${EXECDIR}/use_cases/customer_registration.resource
Resource         ${EXECDIR}/use_cases/customer_access.resource


*** Keywords ***
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
