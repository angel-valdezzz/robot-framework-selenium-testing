*** Settings ***
Documentation    Apertura, transferencia y verificación de saldos por UI.

Variables        ${EXECDIR}/pages/banking_page.py
Resource         ${EXECDIR}/use_cases/customer_evidence.resource


*** Keywords ***
Abrir Cuenta De Ahorro
    [Documentation]    Abre una cuenta y devuelve su número y la cuenta que la financió.
    Preparar Apertura De Ahorro
    ${source}=    Get Selected List Value    ${BANKING_PAGE.funding_account}
    Click Element    ${BANKING_PAGE.open_submit}
    Wait Until Element Is Visible    ${BANKING_PAGE.new_account}
    ${target}=    Get Text    ${BANKING_PAGE.new_account}
    Should Not Be Empty    ${target}
    Should Not Be Equal    ${source}    ${target}
    Documentar Resultado Bancario    ${BANKING_PAGE.new_account}    Cuenta de ahorro abierta    2
    RETURN    ${source}    ${target}

Consultar Saldo De Cuenta
    [Documentation]    Consulta el detalle y devuelve el saldo decimal sin símbolos monetarios.
    [Arguments]    ${account_id}
    Go To    ${BASE_URL}activity.htm?id=${account_id}
    Wait Until Element Is Visible    ${BANKING_PAGE.account_id}
    Wait Until Keyword Succeeds
    ...    10s
    ...    200ms
    ...    Element Text Should Be
    ...    ${BANKING_PAGE.account_id}
    ...    ${account_id}
    ${text}=    Get Text    ${BANKING_PAGE.balance}
    Should Not Be Empty    ${text}
    ${balance}=    Evaluate    decimal.Decimal($text.replace('$', '').replace(',', ''))    modules=decimal
    RETURN    ${balance}

Transferir Entre Cuentas
    [Documentation]    Transfiere y verifica importe, origen y destino de la confirmación.
    [Arguments]    ${source}    ${target}    ${amount}
    Click Element    ${BANKING_PAGE.transfer}
    Wait Until Element Is Visible    ${BANKING_PAGE.amount}
    Wait Until Page Contains Element    css:#toAccountId option[value="${target}"]
    Input Text    ${BANKING_PAGE.amount}    ${amount}
    Select From List By Value    ${BANKING_PAGE.transfer_from}    ${source}
    Select From List By Value    ${BANKING_PAGE.transfer_to}    ${target}
    Click Element    ${BANKING_PAGE.transfer_submit}
    Verificar Confirmación De Transferencia    ${source}    ${target}    ${amount}

Documentar Resultado Bancario
    [Documentation]    Resalta el resultado, añade un dot y una nota y limpia incluso si falla la captura.
    [Arguments]    ${locator}    ${title}    ${number}
    ${milestone}=    Create Milestone    ${title}
    Highlight Element    ${locator}    color=coral    group=banking
    Add Dot    ${locator}    text=${number}    position=right    group=banking
    Add Note    ${locator}    text=${title}    position=bottom    group=banking
    TRY
        Capture Page Evidence    ${title}    milestone_id=${milestone}    status=PASS
    FINALLY
        Clear Annotations    group=banking
    END

Preparar Apertura De Ahorro
    [Documentation]    Espera la carga de cuentas y selecciona el tipo de ahorro.
    Click Element    ${BANKING_PAGE.open_account}
    Wait Until Element Is Visible    ${BANKING_PAGE.account_type}
    Wait Until Page Contains Element    css:#fromAccountId option
    Select From List By Value    ${BANKING_PAGE.account_type}    1

Verificar Confirmación De Transferencia
    [Documentation]    Comprueba los datos del resultado contra la operación solicitada.
    [Arguments]    ${source}    ${target}    ${amount}
    Wait Until Element Is Visible    ${BANKING_PAGE.transfer_result}
    Element Text Should Be    ${BANKING_PAGE.transfer_result}    Transfer Complete!
    Element Text Should Be    ${BANKING_PAGE.result_from}    ${source}
    Element Text Should Be    ${BANKING_PAGE.result_to}    ${target}
    Element Text Should Be    ${BANKING_PAGE.result_amount}    $${amount}
    Documentar Resultado Bancario    ${BANKING_PAGE.transfer_result}    Transferencia confirmada    3

Transferir Y Comprobar Saldos Y Movimientos
    [Documentation]    Contrasta el débito y crédito con los saldos previos y movimientos visibles.
    ${source}    ${target}=    Abrir Cuenta De Ahorro
    ${before_source}=    Consultar Saldo De Cuenta    ${source}
    ${before_target}=    Consultar Saldo De Cuenta    ${target}
    Transferir Entre Cuentas    ${source}    ${target}    10.00
    ${expected_source}=    Evaluate    $before_source - decimal.Decimal('10.00')    modules=decimal
    Comprobar Saldo Y Movimiento    ${source}    ${expected_source}    Débito registrado    4
    ${expected_target}=    Evaluate    $before_target + decimal.Decimal('10.00')    modules=decimal
    Comprobar Saldo Y Movimiento    ${target}    ${expected_target}    Crédito registrado    5

Comprobar Saldo Y Movimiento
    [Documentation]    Comprueba el saldo exacto y el movimiento de diez dólares.
    [Arguments]    ${account_id}    ${expected}    ${title}    ${number}
    ${actual}=    Consultar Saldo De Cuenta    ${account_id}
    Should Be Equal    ${actual}    ${expected}
    Wait Until Element Is Visible    ${BANKING_PAGE.transactions}
    Wait Until Keyword Succeeds    10s    200ms    Element Should Contain    ${BANKING_PAGE.transactions}    $10.00
    Documentar Resultado Bancario    ${BANKING_PAGE.transactions}    ${title}    ${number}
